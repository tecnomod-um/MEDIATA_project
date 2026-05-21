from __future__ import annotations

import argparse
import re
import urllib.request
from io import BytesIO
from pathlib import Path
from typing import List

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.acroform import AcroForm
from reportlab.pdfgen import canvas


PAGE_WIDTH, PAGE_HEIGHT = A4

LEFT = 1.35 * cm
RIGHT = 1.35 * cm
TOP = 1.15 * cm
BOTTOM = 1.15 * cm

CONTENT_WIDTH = PAGE_WIDTH - LEFT - RIGHT

FONT = "Helvetica"
FONT_BOLD = "Helvetica-Bold"

BODY_SIZE = 9
SMALL_SIZE = 7.6
TITLE_SIZE = 18
H1_SIZE = 13
H2_SIZE = 10.5

LINE = 11
SMALL_LINE = 9
BOX = 8

PARAGRAPH_BOTTOM_GAP = 3
PARAGRAPH_BEFORE_TABLE_GAP = -5
TABLE_BOTTOM_GAP = 12
SCALE_ITEM_GAP = 8

LOGO_URL = "https://github.com/user-attachments/assets/ed5d54ab-8f39-42c9-841d-fa052d8dcea5"
LINK_COLOR = colors.HexColor("#0b63b6")


class FillableQuestionnairePdf:
    def __init__(self, output_path: Path, fillable: bool = True):
        self.c = canvas.Canvas(str(output_path), pagesize=A4)
        self.form: AcroForm = self.c.acroForm
        self.y = PAGE_HEIGHT - TOP
        self.page_no = 1
        self.field_no = 1
        self.fillable = fillable
        self.title_top_padding = 0
        self.title_bottom_gap = 28
        self.c._doc.needAppearances = True

    def field_name(self, prefix: str) -> str:
        name = f"{prefix}_{self.field_no:04d}"
        self.field_no += 1
        return name

    def save(self) -> None:
        self.add_footer()
        self.c.save()

    def add_footer(self) -> None:
        self.c.setFont(FONT, 8)
        self.c.setFillColor(colors.HexColor("#666666"))
        self.c.drawRightString(PAGE_WIDTH - RIGHT, 0.72 * cm, f"Page {self.page_no}")
        self.c.setFillColor(colors.black)

    def new_page(self) -> None:
        self.add_footer()
        self.c.showPage()
        self.page_no += 1
        self.y = PAGE_HEIGHT - TOP

    def ensure_space(self, height: float) -> None:
        if self.y - height < BOTTOM:
            self.new_page()

    def wrap_lines(self, text: str, width: float, font: str, size: float) -> List[str]:
        text = clean_inline(text)
        output: List[str] = []

        for forced_line in text.split("\n"):
            words = forced_line.split()

            if not words:
                output.append("")
                continue

            current = ""

            for word in words:
                candidate = word if not current else f"{current} {word}"

                if self.c.stringWidth(candidate, font, size) <= width:
                    current = candidate
                else:
                    if current:
                        output.append(current)
                    current = word

            if current:
                output.append(current)

        return output

    def draw_wrapped(
        self,
        text: str,
        x: float,
        y: float,
        width: float,
        font: str = FONT,
        size: float = BODY_SIZE,
        leading: float = LINE,
    ) -> float:
        self.c.setFont(font, size)

        for line in self.wrap_lines(text, width, font, size):
            if line:
                self.c.drawString(x, y, line)
            y -= leading

        return y

    def draw_wrapped_rich(
        self,
        text: str,
        x: float,
        y: float,
        width: float,
        font: str = FONT,
        size: float = BODY_SIZE,
        leading: float = LINE,
    ) -> float:
        segments = parse_markdown_link_segments(text)

        if not any(url for _, url in segments):
            return self.draw_wrapped(text, x, y, width, font, size, leading)

        self.c.setFont(font, size)
        space_width = self.c.stringWidth(" ", font, size)
        lines: List[List[tuple[str, str | None, int | None, bool]]] = []
        current_line: List[tuple[str, str | None, int | None, bool]] = []

        def line_width(tokens: List[tuple[str, str | None, int | None, bool]]) -> float:
            total = 0.0
            for index, (word, _, _, leading_space) in enumerate(tokens):
                if index and leading_space:
                    total += space_width
                total += self.c.stringWidth(word, font, size)
            return total

        pending_space = False

        for segment_index, (segment_text, url) in enumerate(segments):
            link_id = segment_index if url else None
            parts = segment_text.split("\n")

            for part_index, part in enumerate(parts):
                if part_index > 0:
                    if current_line:
                        lines.append(current_line)
                        current_line = []
                    else:
                        lines.append([])
                    pending_space = False

                previous_end = 0
                matched = False

                for match in re.finditer(r"\S+", part):
                    matched = True
                    word = match.group(0)
                    leading_space = pending_space or bool(part[previous_end:match.start()].strip() == "" and part[previous_end:match.start()])
                    token = (word, url, link_id, leading_space)
                    candidate = current_line + [token]

                    if current_line and line_width(candidate) > width:
                        lines.append(current_line)
                        current_line = [(word, url, link_id, False)]
                    else:
                        current_line = candidate

                    pending_space = False
                    previous_end = match.end()

                if matched:
                    pending_space = bool(part[previous_end:].strip() == "" and part[previous_end:])
                elif part:
                    pending_space = pending_space or bool(part.strip() == "")

        if current_line or not lines:
            lines.append(current_line)

        for line_tokens in lines:
            cursor_x = x

            if not line_tokens:
                y -= leading
                continue

            active_link_url = None
            active_link_id = None
            active_link_start = None
            active_link_end = None

            def close_link() -> None:
                nonlocal active_link_url, active_link_id, active_link_start, active_link_end

                if active_link_url and active_link_start is not None and active_link_end is not None:
                    underline_y = y - 1.2
                    self.c.setLineWidth(0.6)
                    self.c.setStrokeColor(LINK_COLOR)
                    self.c.line(active_link_start, underline_y, active_link_end, underline_y)
                    self.c.linkURL(
                        active_link_url,
                        (active_link_start, y - 2, active_link_end, y + size),
                        relative=not has_uri_scheme(active_link_url),
                    )
                    self.c.setStrokeColor(colors.black)

                active_link_url = None
                active_link_id = None
                active_link_start = None
                active_link_end = None

            for index, (word, url, link_id, leading_space) in enumerate(line_tokens):
                prefix = " " if index and leading_space else ""
                prefix_width = self.c.stringWidth(prefix, font, size)
                word_x = cursor_x + prefix_width
                word_width = self.c.stringWidth(word, font, size)

                if active_link_url and (url != active_link_url or link_id != active_link_id):
                    close_link()

                if url:
                    self.c.setFillColor(LINK_COLOR)
                    if not active_link_url:
                        active_link_url = url
                        active_link_id = link_id
                        active_link_start = word_x
                    active_link_end = word_x + word_width
                else:
                    self.c.setFillColor(colors.black)

                self.c.drawString(cursor_x, y, f"{prefix}{word}")

                cursor_x += prefix_width + word_width

            close_link()
            y -= leading

        self.c.setFillColor(colors.black)
        self.c.setStrokeColor(colors.black)
        return y

    def paragraph(self, text: str, bottom_gap: float = PARAGRAPH_BOTTOM_GAP) -> None:
        scale_items = parse_scale_items(text)

        if scale_items:
            self.scale_legend(scale_items)
            return

        height = estimate_text_height(text, CONTENT_WIDTH, BODY_SIZE, LINE)
        self.ensure_space(height + max(bottom_gap, 0))
        self.y = self.draw_wrapped_rich(text, LEFT, self.y, CONTENT_WIDTH, FONT, BODY_SIZE, LINE)
        self.y -= bottom_gap

    def scale_legend(self, items: List[str]) -> None:
        row_height = 16
        self.ensure_space(row_height + 8)

        labels = ["Scale"] + [clean_inline(item) for item in items]
        min_widths = [self.c.stringWidth(label, FONT, SMALL_SIZE) + 12 for label in labels]
        total_width = sum(min_widths)

        if total_width > CONTENT_WIDTH:
            scale = CONTENT_WIDTH / total_width
            widths = [width * scale for width in min_widths]
        else:
            widths = min_widths

        x = LEFT
        y_bottom = self.y - row_height

        self.c.setFont(FONT_BOLD, SMALL_SIZE)
        self.c.setFillColor(colors.HexColor("#eeeeee"))
        self.c.rect(x, y_bottom, widths[0], row_height, stroke=0, fill=1)
        self.c.setFillColor(colors.black)

        for index, (label, width) in enumerate(zip(labels, widths)):
            self.c.setStrokeColor(colors.HexColor("#999999"))
            self.c.setLineWidth(0.35)
            self.c.rect(x, y_bottom, width, row_height, stroke=1, fill=0)
            self.c.setFont(FONT_BOLD if index == 0 else FONT, SMALL_SIZE)
            self.c.drawString(x + 4, y_bottom + 5, label)
            x += width

        self.y = y_bottom - 14

    def bullet(self, text: str) -> None:
        height = estimate_text_height(text, CONTENT_WIDTH - 14, BODY_SIZE, LINE)
        self.ensure_space(height + 3)
        self.c.setFont(FONT, BODY_SIZE)
        self.c.drawString(LEFT, self.y, "-")
        self.y = self.draw_wrapped_rich(text, LEFT + 14, self.y, CONTENT_WIDTH - 14, FONT, BODY_SIZE, LINE)
        self.y -= 3

    def numbered_item(self, marker: str, text: str) -> None:
        marker = clean_inline(marker)
        marker_width = self.c.stringWidth(marker, FONT, BODY_SIZE)
        indent = marker_width + 8
        height = estimate_text_height(text, CONTENT_WIDTH - indent, BODY_SIZE, LINE)
        self.ensure_space(height + 3)
        self.c.setFont(FONT, BODY_SIZE)
        self.c.drawString(LEFT, self.y, marker)
        self.y = self.draw_wrapped_rich(text, LEFT + indent, self.y, CONTENT_WIDTH - indent, FONT, BODY_SIZE, LINE)
        self.y -= 3

    def title(self, text: str) -> None:
        self.ensure_space(95 + self.title_top_padding)
        self.y -= self.title_top_padding

        logo_reader = load_logo(LOGO_URL)

        if logo_reader:
            image_width, image_height = logo_reader.getSize()
            target_width = 4.7 * cm
            target_height = target_width * image_height / image_width
            x = (PAGE_WIDTH - target_width) / 2

            self.c.drawImage(
                logo_reader,
                x,
                self.y - target_height,
                width=target_width,
                height=target_height,
                mask="auto",
            )
            self.y -= target_height + 20

        self.c.setFont(FONT_BOLD, TITLE_SIZE)
        clean_text = clean_inline(text)
        text_width = self.c.stringWidth(clean_text, FONT_BOLD, TITLE_SIZE)
        self.c.drawString((PAGE_WIDTH - text_width) / 2, self.y, clean_text)
        self.y -= self.title_bottom_gap

    def h1(self, text: str) -> None:
        self.ensure_space(70)
        self.y -= 5
        self.c.setFont(FONT_BOLD, H1_SIZE)
        self.c.drawString(LEFT, self.y, clean_inline(text))
        self.y -= 18

    def h2(self, text: str) -> None:
        self.ensure_space(62)
        self.y -= 7
        self.c.setFont(FONT_BOLD, H2_SIZE)
        self.c.drawString(LEFT, self.y, clean_inline(text))
        self.y -= 10

    def draw_text_field(
        self,
        x: float,
        y_top: float,
        width: float,
        height: float,
        multiline: bool = False,
        prefix: str = "text",
    ) -> None:
        if not self.fillable:
            self.c.setStrokeColor(colors.HexColor("#777777"))
            self.c.setLineWidth(0.6)
            self.c.rect(x, y_top - height, width, height, stroke=1, fill=0)
            return

        self.form.textfield(
            name=self.field_name(prefix),
            tooltip="Type here",
            x=x,
            y=y_top - height,
            width=width,
            height=height,
            borderWidth=0.6,
            borderColor=colors.HexColor("#777777"),
            fillColor=colors.white,
            textColor=colors.black,
            forceBorder=True,
            fontName=FONT,
            fontSize=8,
            fieldFlags="multiline" if multiline else "",
        )

    def draw_checkbox(self, x: float, y_center: float, label: str = "") -> None:
        if self.fillable:
            self.form.checkbox(
                name=self.field_name("check"),
                tooltip=label or "Select",
                x=x,
                y=y_center - BOX / 2,
                size=BOX,
                borderWidth=0.75,
                borderColor=colors.HexColor("#555555"),
                fillColor=colors.white,
                textColor=colors.black,
                buttonStyle="check",
                forceBorder=True,
                checked=False,
            )
        else:
            self.c.setStrokeColor(colors.HexColor("#555555"))
            self.c.setLineWidth(0.75)
            self.c.rect(x, y_center - BOX / 2, BOX, BOX, stroke=1, fill=0)

        if label:
            self.c.setFont(FONT, SMALL_SIZE)
            self.c.setFillColor(colors.black)
            self.c.drawString(x + BOX + 3, y_center - 3, clean_inline(label))

    def draw_checkbox_options(self, content: str, x: float, y: float, width: float) -> None:
        content = content.strip()

        if content == "☐":
            self.draw_checkbox(x + width / 2 - BOX / 2, y)
            return

        labels = [part.strip() for part in content.split("☐") if part.strip()]
        cursor_x = x
        cursor_y = y + 1

        for label in labels:
            label = clean_inline(label)
            has_inline_text_field = label.endswith(":")
            label_width = self.c.stringWidth(label, FONT, SMALL_SIZE) + BOX + 8
            field_width = 70 if has_inline_text_field else 0
            total_width = label_width + field_width + 4

            if cursor_x + total_width > x + width and cursor_x > x:
                cursor_x = x
                cursor_y -= 11

            self.draw_checkbox(cursor_x, cursor_y, label)

            if has_inline_text_field:
                field_x = cursor_x + label_width + 2
                self.draw_text_field(
                    field_x,
                    cursor_y + 6,
                    min(field_width, x + width - field_x),
                    11,
                    multiline=False,
                    prefix="other",
                )

            cursor_x += total_width

    def draw_cell_text(self, text: str, x: float, y: float, width: float) -> None:
        self.draw_wrapped(text, x, y, width, FONT, SMALL_SIZE, SMALL_LINE)

    def draw_table(self, rows: List[List[str]]) -> None:
        if not rows:
            return

        rows = [row for row in rows if not is_separator_row(row)]
        rows = normalize_rows(rows)

        column_count = max(len(row) for row in rows)
        column_widths = get_column_widths(column_count, rows)
        row_heights = [estimate_table_row_height(row, column_widths) for row in rows]

        if len(row_heights) >= 2:
            self.ensure_space(row_heights[0] + row_heights[1] + 4)

        for row_index, row in enumerate(rows):
            row_height = row_heights[row_index]
            self.ensure_space(row_height + 4)

            y_top = self.y
            y_bottom = y_top - row_height

            if row_index == 0:
                self.c.setFillColor(colors.HexColor("#eeeeee"))
                self.c.rect(LEFT, y_bottom, sum(column_widths), row_height, stroke=0, fill=1)
                self.c.setFillColor(colors.black)

            x_cursor = LEFT

            for width in column_widths:
                self.c.setStrokeColor(colors.HexColor("#999999"))
                self.c.setLineWidth(0.35)
                self.c.rect(x_cursor, y_bottom, width, row_height, stroke=1, fill=0)
                x_cursor += width

            x_cursor = LEFT

            for column_index, cell in enumerate(row):
                width = column_widths[column_index]
                content = cell.strip()
                cell_x = x_cursor + 3
                cell_y = y_top - 10

                if row_index == 0:
                    self.c.setFont(FONT_BOLD, SMALL_SIZE)
                    self.c.drawString(cell_x, cell_y, clean_inline(content))
                elif is_checkbox_options(content):
                    self.draw_checkbox_options(content, cell_x, y_top - 10, width - 6)
                elif should_be_text_field(row, column_index, content):
                    self.draw_text_field(
                        cell_x,
                        y_top - 3,
                        width - 6,
                        row_height - 6,
                        multiline=row_height > 24,
                    )
                else:
                    self.draw_cell_text(content, cell_x, y_top - 10, width - 6)

                x_cursor += width

            self.y = y_bottom

        self.y -= TABLE_BOTTOM_GAP

    def open_question_field(self, question: str, number: int) -> None:
        self.ensure_space(62)
        self.y = self.draw_wrapped(
            f"{number}. {question}",
            LEFT,
            self.y,
            CONTENT_WIDTH,
            FONT,
            BODY_SIZE,
            LINE,
        )
        self.y -= 3
        self.draw_text_field(
            LEFT,
            self.y,
            CONTENT_WIDTH,
            34,
            multiline=True,
            prefix="open_answer",
        )
        self.y -= 44


def load_logo(url: str) -> ImageReader | None:
    try:
        with urllib.request.urlopen(url, timeout=20) as response:
            return ImageReader(BytesIO(response.read()))
    except Exception:
        return None


def strip_basic_markdown(text: str) -> str:
    text = text.strip()
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"\1", text)
    text = re.sub(r"\*([^*]+)\*", r"\1", text)
    return text


def clean_inline(text: str) -> str:
    text = strip_basic_markdown(text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r"\1", text)
    return text


def parse_markdown_link_segments(text: str) -> List[tuple[str, str | None]]:
    text = strip_basic_markdown(text)
    pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    segments: List[tuple[str, str | None]] = []
    cursor = 0

    for match in pattern.finditer(text):
        if match.start() > cursor:
            segments.append((text[cursor:match.start()], None))
        segments.append((match.group(1), match.group(2)))
        cursor = match.end()

    if cursor < len(text):
        segments.append((text[cursor:], None))

    return segments


def has_uri_scheme(url: str) -> bool:
    return bool(re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", url))


def parse_scale_items(text: str) -> List[str]:
    normalized = clean_inline(text).replace("\n", " ")

    if "Very easy" in normalized and "Very difficult" in normalized:
        return [
            "1 = Very easy",
            "2 = Easy",
            "3 = Neutral",
            "4 = Difficult",
            "5 = Very difficult",
            "N/A = Not completed or not available",
        ]

    if "Strongly disagree" in normalized and "Strongly agree" in normalized:
        return [
            "1 = Strongly disagree",
            "2 = Disagree",
            "3 = Neutral",
            "4 = Agree",
            "5 = Strongly agree",
        ]

    return []


def join_paragraph_buffer(buffer: List[str]) -> str:
    output = ""

    for item in buffer:
        if item == "\n":
            output = output.rstrip() + "\n"
        elif not output:
            output = item
        elif output.endswith("\n"):
            output += item
        else:
            output += " " + item

    return output


def estimate_text_height(text: str, width: float, size: float, leading: float) -> float:
    cleaned = clean_inline(text)
    average_character_width = size * 0.48
    characters_per_line = max(20, int(width / average_character_width))

    total_lines = 0

    for forced_line in cleaned.split("\n"):
        if not forced_line.strip():
            total_lines += 1
            continue

        total_lines += max(1, (len(forced_line) // characters_per_line) + 1)

    return max(1, total_lines) * leading


def is_table_line(line: str) -> bool:
    stripped = line.strip()
    return stripped.startswith("|") and stripped.endswith("|")


def split_table_row(line: str) -> List[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def is_separator_row(row: List[str]) -> bool:
    return all(re.fullmatch(r":?-{3,}:?", cell.strip()) for cell in row)


def normalize_rows(rows: List[List[str]]) -> List[List[str]]:
    max_columns = max(len(row) for row in rows)
    return [row + [""] * (max_columns - len(row)) for row in rows]


def get_column_widths(column_count: int, rows: List[List[str]] | None = None) -> List[float]:
    header = [cell.strip().lower() for cell in rows[0]] if rows else []

    if column_count == 2:
        return [CONTENT_WIDTH * 0.37, CONTENT_WIDTH * 0.63]

    if column_count == 6:
        return [CONTENT_WIDTH * 0.50] + [CONTENT_WIDTH * 0.10] * 5

    if column_count == 7:
        if header and header[0] == "task":
            return [CONTENT_WIDTH * 0.52] + [CONTENT_WIDTH * 0.08] * 6

        return [CONTENT_WIDTH * 0.08, CONTENT_WIDTH * 0.56] + [CONTENT_WIDTH * 0.072] * 5

    if column_count == 8:
        return [CONTENT_WIDTH * 0.40] + [CONTENT_WIDTH * 0.085] * 6 + [CONTENT_WIDTH * 0.09]

    return [CONTENT_WIDTH / column_count] * column_count


def estimate_table_row_height(row: List[str], widths: List[float]) -> float:
    row_text = " ".join(row).lower()

    if row and row[0].strip().lower() in {
        "access the release",
        "review the tutorial",
        "find available datasets",
        "inspect dataset metadata",
        "explore dataset structure",
        "review data summaries",
        "use filters or search controls",
        "find the target schema",
        "map fields to the target schema",
        "map values to common values",
        "review the integrated structure",
        "save or export the work",
    }:
        return 20

    max_lines = 1

    for cell, width in zip(row, widths):
        if cell.strip() == "☐":
            lines = 1
        elif is_checkbox_options(cell):
            labels = [part.strip() for part in cell.split("☐") if part.strip()]
            total_characters = sum(len(label) + 4 for label in labels)
            approximate_characters = max(12, int(width / 4.2))
            lines = max(1, (total_characters // approximate_characters) + 1)
        else:
            approximate_characters = max(12, int(width / 3.8))
            lines = max(1, (len(clean_inline(cell)) // approximate_characters) + 1)

        max_lines = max(max_lines, lines)

    base_height = max(18, max_lines * SMALL_LINE + 8)

    if "comments" in row_text:
        return max(base_height, 30)

    return base_height


def is_checkbox_options(content: str) -> bool:
    return "☐" in content


def should_be_text_field(row: List[str], column_index: int, content: str) -> bool:
    if column_index == 1 and content == "":
        return True

    first_cell = row[0].strip().lower() if row else ""

    if column_index == 1 and first_cell in {
        "comments",
        "participant code",
        "participant code or initials",
        "date",
        "date of evaluation",
        "optional signature/name",
    }:
        return True

    return False


def is_page_break_marker(stripped_line: str) -> bool:
    return stripped_line.lower() in {
        "<!-- pagebreak -->",
        "<!-- page-break -->",
        "\\pagebreak",
        "[[pagebreak]]",
    }


def next_content_line(lines: List[str], start_index: int) -> str:
    for candidate in lines[start_index:]:
        stripped = candidate.strip()
        if stripped and stripped != "---":
            return stripped
    return ""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate MEDIATA evaluation PDFs.")
    parser.add_argument(
        "--questionnaire-input",
        default="evaluation/templates/questionnaire_template.md",
    )
    parser.add_argument(
        "--tasks-input",
        default="evaluation/templates/tasks_template.md",
    )
    parser.add_argument(
        "--questionnaire-output",
        default="evaluation/questionnaire.pdf",
    )
    parser.add_argument(
        "--tasks-output",
        default="evaluation/evaluation_tasks.pdf",
    )
    return parser.parse_args()


def build_pdf(markdown_path: Path, output_path: Path, fillable: bool) -> None:
    if not markdown_path.exists():
        raise FileNotFoundError(f"Markdown template not found: {markdown_path}")

    output_path.parent.mkdir(parents=True, exist_ok=True)

    pdf = FillableQuestionnairePdf(output_path, fillable=fillable)

    lines = markdown_path.read_text(encoding="utf-8").splitlines()

    paragraph_buffer: List[str] = []
    table_buffer: List[List[str]] = []

    in_open_questions = False
    open_question_number = 0

    def flush_paragraph(bottom_gap: float = PARAGRAPH_BOTTOM_GAP) -> None:
        nonlocal paragraph_buffer

        if paragraph_buffer:
            pdf.paragraph(join_paragraph_buffer(paragraph_buffer), bottom_gap=bottom_gap)
            paragraph_buffer = []

    def flush_table() -> None:
        nonlocal table_buffer

        if table_buffer:
            pdf.draw_table(table_buffer)
            table_buffer = []

    for index, raw_line in enumerate(lines):
        hard_break = raw_line.endswith("  ")
        line = raw_line.rstrip()
        stripped = line.strip()

        if is_table_line(line):
            flush_paragraph(bottom_gap=PARAGRAPH_BEFORE_TABLE_GAP)
            table_buffer.append(split_table_row(line))
            continue

        flush_table()

        if not stripped:
            next_line = next_content_line(lines, index + 1)
            if is_table_line(next_line):
                flush_paragraph(bottom_gap=PARAGRAPH_BEFORE_TABLE_GAP)
            else:
                flush_paragraph(bottom_gap=PARAGRAPH_BOTTOM_GAP)
            continue

        if is_page_break_marker(stripped):
            flush_paragraph()
            flush_table()

            if pdf.y < PAGE_HEIGHT - TOP - 1:
                pdf.new_page()

            continue

        if stripped == "---":
            flush_paragraph()
            pdf.y -= 4
            continue

        if stripped.startswith("# "):
            flush_paragraph()
            pdf.title(stripped[2:])
            continue

        if stripped.startswith("## "):
            flush_paragraph()
            heading = stripped[3:]
            pdf.h1(heading)
            in_open_questions = heading.lower().startswith("7. open questions")
            continue

        if stripped.startswith("### "):
            flush_paragraph()
            pdf.h2(stripped[4:])
            continue

        if in_open_questions:
            match = re.match(r"^(\d+)\.\s+(.*)$", stripped)

            if match:
                open_question_number += 1
                pdf.open_question_field(match.group(2), open_question_number)
                continue

        if re.match(r"^\s*[-*]\s+", line):
            flush_paragraph()
            pdf.bullet(re.sub(r"^\s*[-*]\s+", "", stripped))
            continue

        numbered_match = re.match(r"^(\d+\.)\s+(.*)$", stripped)
        if numbered_match:
            flush_paragraph()
            pdf.numbered_item(numbered_match.group(1), numbered_match.group(2))
            continue

        paragraph_buffer.append(stripped)

        if hard_break:
            paragraph_buffer.append("\n")

    flush_paragraph()
    flush_table()
    pdf.save()


def main() -> None:
    args = parse_args()

    build_pdf(
        Path(args.questionnaire_input),
        Path(args.questionnaire_output),
        fillable=True,
    )

    build_pdf(
        Path(args.tasks_input),
        Path(args.tasks_output),
        fillable=False,
    )

    print(f"Generated questionnaire PDF: {args.questionnaire_output}")
    print(f"Generated evaluation tasks PDF: {args.tasks_output}")


if __name__ == "__main__":
    main()

#define SDL_MAIN_HANDLED
#include <SDL.h>

#include <ctype.h>
#include <math.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#define WINDOW_WIDTH 1280
#define WINDOW_HEIGHT 720
#define AXIS_DEADZONE 4096
#define EXIT_COMBO_TIMEOUT_MS 1500

typedef struct {
    char ch;
    Uint8 rows[7];
} Glyph;

typedef struct {
    SDL_Window *window;
    SDL_Renderer *renderer;
    SDL_GameController *controller;
    SDL_JoystickID instance_id;
    bool rumble_supported;
    bool trigger_rumble_supported;
    bool rumble_demo_enabled;
    Uint32 last_demo_tick;
    char controller_name[128];
    char status_line[192];
    char last_input[96];
    Sint16 axes[SDL_CONTROLLER_AXIS_MAX];
    Uint8 buttons[SDL_CONTROLLER_BUTTON_MAX];
    Uint8 hat_state;
    Uint32 last_exit_combo_tick;
    Uint8 exit_combo_count;
    bool exit_combo_held;
    bool suppress_back_release;
    bool suppress_start_release;
} AppState;

#define GLYPH(ch, a, b, c, d, e, f, g) { ch, { a, b, c, d, e, f, g } }

static const Glyph FONT[] = {
    GLYPH(' ', 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00),
    GLYPH('+', 0x00, 0x04, 0x04, 0x1f, 0x04, 0x04, 0x00),
    GLYPH('-', 0x00, 0x00, 0x00, 0x1f, 0x00, 0x00, 0x00),
    GLYPH('.', 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x06),
    GLYPH('/', 0x01, 0x02, 0x04, 0x08, 0x10, 0x00, 0x00),
    GLYPH(':', 0x00, 0x04, 0x04, 0x00, 0x04, 0x04, 0x00),
    GLYPH('=', 0x00, 0x1f, 0x00, 0x1f, 0x00, 0x00, 0x00),
    GLYPH('?', 0x0e, 0x11, 0x01, 0x02, 0x04, 0x00, 0x04),
    GLYPH('_', 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1f),
    GLYPH('0', 0x0e, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0e),
    GLYPH('1', 0x04, 0x0c, 0x04, 0x04, 0x04, 0x04, 0x0e),
    GLYPH('2', 0x0e, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1f),
    GLYPH('3', 0x1e, 0x01, 0x01, 0x0e, 0x01, 0x01, 0x1e),
    GLYPH('4', 0x02, 0x06, 0x0a, 0x12, 0x1f, 0x02, 0x02),
    GLYPH('5', 0x1f, 0x10, 0x10, 0x1e, 0x01, 0x01, 0x1e),
    GLYPH('6', 0x0e, 0x10, 0x10, 0x1e, 0x11, 0x11, 0x0e),
    GLYPH('7', 0x1f, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08),
    GLYPH('8', 0x0e, 0x11, 0x11, 0x0e, 0x11, 0x11, 0x0e),
    GLYPH('9', 0x0e, 0x11, 0x11, 0x0f, 0x01, 0x01, 0x0e),
    GLYPH('A', 0x0e, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11),
    GLYPH('B', 0x1e, 0x11, 0x11, 0x1e, 0x11, 0x11, 0x1e),
    GLYPH('C', 0x0e, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0e),
    GLYPH('D', 0x1e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1e),
    GLYPH('E', 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x1f),
    GLYPH('F', 0x1f, 0x10, 0x10, 0x1e, 0x10, 0x10, 0x10),
    GLYPH('G', 0x0e, 0x11, 0x10, 0x17, 0x11, 0x11, 0x0e),
    GLYPH('H', 0x11, 0x11, 0x11, 0x1f, 0x11, 0x11, 0x11),
    GLYPH('I', 0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x1f),
    GLYPH('J', 0x07, 0x02, 0x02, 0x02, 0x12, 0x12, 0x0c),
    GLYPH('K', 0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11),
    GLYPH('L', 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1f),
    GLYPH('M', 0x11, 0x1b, 0x15, 0x15, 0x11, 0x11, 0x11),
    GLYPH('N', 0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11),
    GLYPH('O', 0x0e, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e),
    GLYPH('P', 0x1e, 0x11, 0x11, 0x1e, 0x10, 0x10, 0x10),
    GLYPH('Q', 0x0e, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0d),
    GLYPH('R', 0x1e, 0x11, 0x11, 0x1e, 0x14, 0x12, 0x11),
    GLYPH('S', 0x0f, 0x10, 0x10, 0x0e, 0x01, 0x01, 0x1e),
    GLYPH('T', 0x1f, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04),
    GLYPH('U', 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0e),
    GLYPH('V', 0x11, 0x11, 0x11, 0x11, 0x11, 0x0a, 0x04),
    GLYPH('W', 0x11, 0x11, 0x11, 0x15, 0x15, 0x15, 0x0a),
    GLYPH('X', 0x11, 0x11, 0x0a, 0x04, 0x0a, 0x11, 0x11),
    GLYPH('Y', 0x11, 0x11, 0x0a, 0x04, 0x04, 0x04, 0x04),
    GLYPH('Z', 0x1f, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1f)
};

static const SDL_Color COLOR_BACKGROUND = { 245, 241, 252, 255 };
static const SDL_Color COLOR_BAR = { 90, 56, 180, 255 };
static const SDL_Color COLOR_BAR_ALT = { 106, 68, 196, 255 };
static const SDL_Color COLOR_LINE = { 96, 62, 190, 255 };
static const SDL_Color COLOR_FILL = { 214, 198, 247, 255 };
static const SDL_Color COLOR_TEXT = { 90, 56, 180, 255 };
static const SDL_Color COLOR_TEXT_INVERSE = { 255, 255, 255, 255 };
static const SDL_Color COLOR_FAINT = { 168, 154, 214, 255 };
static const SDL_Color COLOR_DARK = { 58, 36, 135, 255 };

static void set_color(SDL_Renderer *renderer, SDL_Color color)
{
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
}

static int scale_value(int value, float scale)
{
    int scaled = (int)lroundf((float)value * scale);

    if (scaled < 1) {
        return 1;
    }
    return scaled;
}

static int scale_font(int value, float scale)
{
    int scaled = (int)lroundf((float)value * scale);

    if (scaled < 1) {
        return 1;
    }
    return scaled;
}

static void fill_rect(SDL_Renderer *renderer, int x, int y, int w, int h, SDL_Color color)
{
    SDL_Rect rect = { x, y, w, h };

    set_color(renderer, color);
    SDL_RenderFillRect(renderer, &rect);
}

static void draw_rect(SDL_Renderer *renderer, int x, int y, int w, int h, SDL_Color color)
{
    set_color(renderer, color);
    for (int i = 0; i < 2; ++i) {
        SDL_Rect rect = { x + i, y + i, w - (i * 2), h - (i * 2) };

        if (rect.w > 0 && rect.h > 0) {
            SDL_RenderDrawRect(renderer, &rect);
        }
    }
}

static void draw_hline(SDL_Renderer *renderer, int x1, int x2, int y, SDL_Color color)
{
    set_color(renderer, color);
    SDL_RenderDrawLine(renderer, x1, y, x2, y);
    SDL_RenderDrawLine(renderer, x1, y + 1, x2, y + 1);
}

static void draw_vline(SDL_Renderer *renderer, int x, int y1, int y2, SDL_Color color)
{
    set_color(renderer, color);
    SDL_RenderDrawLine(renderer, x, y1, x, y2);
    SDL_RenderDrawLine(renderer, x + 1, y1, x + 1, y2);
}

static void fill_circle(SDL_Renderer *renderer, int center_x, int center_y, int radius, SDL_Color color)
{
    int radius_sq = radius * radius;

    set_color(renderer, color);
    for (int dy = -radius; dy <= radius; ++dy) {
        for (int dx = -radius; dx <= radius; ++dx) {
            if ((dx * dx) + (dy * dy) <= radius_sq) {
                SDL_RenderDrawPoint(renderer, center_x + dx, center_y + dy);
            }
        }
    }
}

static void draw_circle_outline(SDL_Renderer *renderer, int center_x, int center_y, int radius, int thickness, SDL_Color color)
{
    int outer = radius * radius;
    int inner_radius = radius - thickness;
    int inner = inner_radius > 0 ? inner_radius * inner_radius : 0;

    set_color(renderer, color);
    for (int dy = -radius; dy <= radius; ++dy) {
        for (int dx = -radius; dx <= radius; ++dx) {
            int dist = (dx * dx) + (dy * dy);

            if (dist <= outer && dist >= inner) {
                SDL_RenderDrawPoint(renderer, center_x + dx, center_y + dy);
            }
        }
    }
}

static const Uint8 *glyph_rows(char ch)
{
    char upper = (char)toupper((unsigned char)ch);

    for (size_t i = 0; i < SDL_arraysize(FONT); ++i) {
        if (FONT[i].ch == upper) {
            return FONT[i].rows;
        }
    }

    return FONT[0].rows;
}

static int text_pixel_width(const char *text, int scale)
{
    size_t length = SDL_strlen(text);

    if (length == 0) {
        return 0;
    }

    return (int)((length * 6U * (unsigned)scale) - (unsigned)scale);
}

static void draw_text(SDL_Renderer *renderer, int x, int y, int scale, SDL_Color color, const char *text)
{
    int cursor = x;

    set_color(renderer, color);
    for (size_t i = 0; text[i] != '\0'; ++i) {
        const Uint8 *rows = glyph_rows(text[i]);

        for (int row = 0; row < 7; ++row) {
            for (int col = 0; col < 5; ++col) {
                if ((rows[row] & (1U << (4 - col))) != 0U) {
                    SDL_Rect pixel = {
                        cursor + (col * scale),
                        y + (row * scale),
                        scale,
                        scale
                    };
                    SDL_RenderFillRect(renderer, &pixel);
                }
            }
        }

        cursor += 6 * scale;
    }
}

static void draw_text_centered(SDL_Renderer *renderer, int center_x, int y, int scale, SDL_Color color, const char *text)
{
    draw_text(renderer, center_x - (text_pixel_width(text, scale) / 2), y, scale, color, text);
}

static void sanitize_label(const char *source, char *destination, size_t destination_size)
{
    size_t out = 0;
    bool previous_space = true;

    if (destination_size == 0) {
        return;
    }

    for (size_t i = 0; source[i] != '\0' && out + 1 < destination_size; ++i) {
        unsigned char ch = (unsigned char)source[i];

        if (isalnum(ch) != 0) {
            destination[out++] = (char)toupper(ch);
            previous_space = false;
        } else if (!previous_space) {
            destination[out++] = ' ';
            previous_space = true;
        }
    }

    while (out > 0 && destination[out - 1] == ' ') {
        --out;
    }

    destination[out] = '\0';
}

static Sint16 filtered_axis(Sint16 value)
{
    if (value > -AXIS_DEADZONE && value < AXIS_DEADZONE) {
        return 0;
    }
    return value;
}

static float normalized_axis(Sint16 value)
{
    Sint16 filtered = filtered_axis(value);

    if (filtered >= 0) {
        return (float)filtered / 32767.0f;
    }
    return (float)filtered / 32768.0f;
}

static float normalized_trigger(Sint16 value)
{
    if (value <= 0) {
        return 0.0f;
    }
    return (float)value / 32767.0f;
}

static void compute_stick_dot_position(
    int center_x,
    int center_y,
    Sint16 axis_x,
    Sint16 axis_y,
    int travel_radius,
    int *dot_x,
    int *dot_y)
{
    float nx = normalized_axis(axis_x);
    float ny = normalized_axis(axis_y);
    float magnitude = sqrtf((nx * nx) + (ny * ny));

    if (magnitude > 1.0f) {
        nx /= magnitude;
        ny /= magnitude;
    }

    *dot_x = center_x + (int)lroundf(nx * (float)travel_radius);
    *dot_y = center_y + (int)lroundf(ny * (float)travel_radius);
}

static void set_status(AppState *app, const char *fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    SDL_vsnprintf(app->status_line, sizeof(app->status_line), fmt, args);
    va_end(args);

    if (app->window != NULL) {
        char title[256];

        SDL_snprintf(title, sizeof(title), "SDL2 Controller Test | %s", app->status_line);
        SDL_SetWindowTitle(app->window, title);
    }

    SDL_Log("%s", app->status_line);
}

static const char *button_name(SDL_GameControllerButton button)
{
    switch (button) {
        case SDL_CONTROLLER_BUTTON_A:
            return "BUTTON A";
        case SDL_CONTROLLER_BUTTON_B:
            return "BUTTON B";
        case SDL_CONTROLLER_BUTTON_X:
            return "BUTTON X";
        case SDL_CONTROLLER_BUTTON_Y:
            return "BUTTON Y";
        case SDL_CONTROLLER_BUTTON_BACK:
            return "BUTTON BACK";
        case SDL_CONTROLLER_BUTTON_GUIDE:
            return "BUTTON GUIDE";
        case SDL_CONTROLLER_BUTTON_START:
            return "BUTTON START";
        case SDL_CONTROLLER_BUTTON_LEFTSTICK:
            return "BUTTON L3";
        case SDL_CONTROLLER_BUTTON_RIGHTSTICK:
            return "BUTTON R3";
        case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:
            return "BUTTON L1";
        case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:
            return "BUTTON R1";
        case SDL_CONTROLLER_BUTTON_DPAD_UP:
            return "DPAD UP";
        case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
            return "DPAD DOWN";
        case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
            return "DPAD LEFT";
        case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
            return "DPAD RIGHT";
        default:
            return "BUTTON";
    }
}

static const char *axis_name(SDL_GameControllerAxis axis)
{
    switch (axis) {
        case SDL_CONTROLLER_AXIS_LEFTX:
            return "AXIS LX";
        case SDL_CONTROLLER_AXIS_LEFTY:
            return "AXIS LY";
        case SDL_CONTROLLER_AXIS_RIGHTX:
            return "AXIS RX";
        case SDL_CONTROLLER_AXIS_RIGHTY:
            return "AXIS RY";
        case SDL_CONTROLLER_AXIS_TRIGGERLEFT:
            return "AXIS L2";
        case SDL_CONTROLLER_AXIS_TRIGGERRIGHT:
            return "AXIS R2";
        default:
            return "AXIS";
    }
}

static void remember_button_event(AppState *app, SDL_GameControllerButton button)
{
    SDL_strlcpy(app->last_input, button_name(button), sizeof(app->last_input));
}

static void remember_axis_event(AppState *app, SDL_GameControllerAxis axis, Sint16 value)
{
    int percent = (int)(normalized_axis(value) * 100.0f);

    if (axis == SDL_CONTROLLER_AXIS_TRIGGERLEFT || axis == SDL_CONTROLLER_AXIS_TRIGGERRIGHT) {
        percent = (int)(normalized_trigger(value) * 100.0f);
    }

    SDL_snprintf(app->last_input, sizeof(app->last_input), "%s %d", axis_name(axis), percent);
}

static void reset_exit_combo_hold(AppState *app)
{
    app->exit_combo_held = false;
    app->suppress_back_release = false;
    app->suppress_start_release = false;
}

static bool register_exit_combo(AppState *app)
{
    Uint32 now = SDL_GetTicks();

    if (app->exit_combo_count == 0 || now - app->last_exit_combo_tick > EXIT_COMBO_TIMEOUT_MS) {
        app->exit_combo_count = 0;
    }

    app->last_exit_combo_tick = now;
    app->exit_combo_count += 1;
    app->exit_combo_held = true;
    app->suppress_back_release = true;
    app->suppress_start_release = true;
    SDL_strlcpy(app->last_input, "START SELECT COMBO", sizeof(app->last_input));

    if (app->exit_combo_count >= 2) {
        set_status(app, "Exit combo confirmed, quitting");
        app->exit_combo_count = 0;
        return true;
    }

    set_status(app, "Exit combo 1/2: press START and SELECT again to quit");
    return false;
}

static void toggle_rumble_demo(AppState *app)
{
    if (app->controller != NULL && app->rumble_supported) {
        app->rumble_demo_enabled = !app->rumble_demo_enabled;
        app->last_demo_tick = 0;
        set_status(
            app,
            "Rumble demo %s on %s",
            app->rumble_demo_enabled ? "enabled" : "disabled",
            app->controller_name);
    } else {
        set_status(app, "Rumble demo unavailable on this controller");
    }
}

static void draw_labeled_button(
    SDL_Renderer *renderer,
    int x,
    int y,
    int w,
    int h,
    const char *label,
    bool pressed,
    int text_scale)
{
    if (pressed) {
        fill_rect(renderer, x + 2, y + 2, w - 3, h - 3, COLOR_FILL);
    }
    draw_rect(renderer, x, y, w, h, COLOR_LINE);
    draw_text_centered(
        renderer,
        x + (w / 2),
        y + ((h - (7 * text_scale)) / 2),
        text_scale,
        pressed ? COLOR_DARK : COLOR_TEXT,
        label);
}

static void draw_trigger_box(
    SDL_Renderer *renderer,
    int x,
    int y,
    int w,
    int h,
    const char *label,
    Sint16 value,
    int text_scale)
{
    int inner_w = (int)((float)(w - 4) * normalized_trigger(value));

    if (inner_w > 0) {
        fill_rect(renderer, x + 2, y + 2, inner_w, h - 3, COLOR_FILL);
    }
    draw_rect(renderer, x, y, w, h, COLOR_LINE);
    draw_text_centered(renderer, x + (w / 2), y + ((h - (7 * text_scale)) / 2), text_scale, COLOR_TEXT, label);
}

static void draw_labeled_circle(
    SDL_Renderer *renderer,
    int center_x,
    int center_y,
    int radius,
    const char *label,
    bool pressed,
    int text_scale)
{
    if (pressed) {
        fill_circle(renderer, center_x, center_y, radius - 2, COLOR_FILL);
    }
    draw_circle_outline(renderer, center_x, center_y, radius, 2, COLOR_LINE);
    draw_text_centered(
        renderer,
        center_x,
        center_y - ((7 * text_scale) / 2),
        text_scale,
        pressed ? COLOR_DARK : COLOR_TEXT,
        label);
}

static void draw_large_stick(
    SDL_Renderer *renderer,
    int center_x,
    int center_y,
    const char *label,
    Sint16 axis_x,
    Sint16 axis_y,
    bool pressed,
    int outer_radius,
    int inner_radius,
    int fill_radius,
    int motion_radius,
    int dot_radius,
    int label_scale)
{
    int dot_x;
    int dot_y;

    compute_stick_dot_position(center_x, center_y, axis_x, axis_y, motion_radius, &dot_x, &dot_y);

    draw_circle_outline(renderer, center_x, center_y, outer_radius, 2, COLOR_LINE);
    draw_circle_outline(renderer, center_x, center_y, inner_radius, 1, COLOR_FAINT);
    draw_hline(renderer, center_x - outer_radius, center_x + outer_radius, center_y, COLOR_FAINT);
    draw_vline(renderer, center_x, center_y - outer_radius, center_y + outer_radius, COLOR_FAINT);

    if (pressed) {
        fill_circle(renderer, center_x, center_y, fill_radius, COLOR_FILL);
    }
    draw_text_centered(renderer, center_x, center_y - ((7 * label_scale) / 2), label_scale, pressed ? COLOR_DARK : COLOR_TEXT, label);
    fill_circle(renderer, dot_x, dot_y, dot_radius, COLOR_LINE);
}

static void draw_dpad(
    SDL_Renderer *renderer,
    int center_x,
    int center_y,
    const AppState *app,
    int center_size,
    int arm_length,
    int arm_thickness,
    int gap)
{
    int center_left = center_x - (center_size / 2);
    int center_top = center_y - (center_size / 2);
    bool up = app->buttons[SDL_CONTROLLER_BUTTON_DPAD_UP] != 0 || (app->hat_state & SDL_HAT_UP) != 0;
    bool down = app->buttons[SDL_CONTROLLER_BUTTON_DPAD_DOWN] != 0 || (app->hat_state & SDL_HAT_DOWN) != 0;
    bool left = app->buttons[SDL_CONTROLLER_BUTTON_DPAD_LEFT] != 0 || (app->hat_state & SDL_HAT_LEFT) != 0;
    bool right = app->buttons[SDL_CONTROLLER_BUTTON_DPAD_RIGHT] != 0 || (app->hat_state & SDL_HAT_RIGHT) != 0;

    if (up) {
        fill_rect(
            renderer,
            center_x - (arm_thickness / 2) + 2,
            center_top - gap - arm_length + 2,
            arm_thickness - 3,
            arm_length - 3,
            COLOR_FILL);
    }
    if (down) {
        fill_rect(
            renderer,
            center_x - (arm_thickness / 2) + 2,
            center_top + center_size + gap + 2,
            arm_thickness - 3,
            arm_length - 3,
            COLOR_FILL);
    }
    if (left) {
        fill_rect(
            renderer,
            center_left - gap - arm_length + 2,
            center_y - (arm_thickness / 2) + 2,
            arm_length - 3,
            arm_thickness - 3,
            COLOR_FILL);
    }
    if (right) {
        fill_rect(
            renderer,
            center_left + center_size + gap + 2,
            center_y - (arm_thickness / 2) + 2,
            arm_length - 3,
            arm_thickness - 3,
            COLOR_FILL);
    }

    draw_rect(renderer, center_x - (arm_thickness / 2), center_top - gap - arm_length, arm_thickness, arm_length, COLOR_LINE);
    draw_rect(renderer, center_x - (arm_thickness / 2), center_top + center_size + gap, arm_thickness, arm_length, COLOR_LINE);
    draw_rect(renderer, center_left - gap - arm_length, center_y - (arm_thickness / 2), arm_length, arm_thickness, COLOR_LINE);
    draw_rect(renderer, center_left + center_size + gap, center_y - (arm_thickness / 2), arm_length, arm_thickness, COLOR_LINE);
}

static void draw_details_panel(
    SDL_Renderer *renderer,
    const AppState *app,
    int x,
    int y,
    int w,
    int h,
    float scale_y,
    int title_scale,
    int body_scale)
{
    char name_line[96];
    char detail_line[96];
    char rumble_line[96];
    char trigger_line[96];

    (void)h;
    sanitize_label(app->controller_name, name_line, sizeof(name_line));
    sanitize_label(app->last_input, detail_line, sizeof(detail_line));
    SDL_snprintf(rumble_line, sizeof(rumble_line), "RUMBLE = %s", app->rumble_supported ? "YES" : "NO");
    SDL_snprintf(trigger_line, sizeof(trigger_line), "TRIGGER RUMBLE = %s", app->trigger_rumble_supported ? "YES" : "NO");

    draw_text_centered(renderer, x + (w / 2), y + scale_value(20, scale_y), title_scale, COLOR_TEXT, "KEY DETAILS");
    if (app->controller == NULL) {
        draw_text_centered(renderer, x + (w / 2), y + scale_value(82, scale_y), body_scale, COLOR_TEXT, "NO CONTROLLER");
        draw_text_centered(renderer, x + (w / 2), y + scale_value(120, scale_y), body_scale, COLOR_TEXT, "WAITING FOR INPUT");
        draw_text_centered(renderer, x + (w / 2), y + scale_value(168, scale_y), body_scale, COLOR_TEXT, "RUMBLE = NO");
        draw_text_centered(renderer, x + (w / 2), y + scale_value(206, scale_y), body_scale, COLOR_TEXT, "TRIGGER RUMBLE = NO");
        return;
    }

    draw_text_centered(
        renderer,
        x + (w / 2),
        y + scale_value(74, scale_y),
        body_scale,
        COLOR_TEXT,
        name_line[0] != '\0' ? name_line : "UNKNOWN CONTROLLER");
    draw_text_centered(
        renderer,
        x + (w / 2),
        y + scale_value(118, scale_y),
        body_scale,
        COLOR_TEXT,
        detail_line[0] != '\0' ? detail_line : "WAITING FOR INPUT");
    draw_text_centered(renderer, x + (w / 2), y + scale_value(168, scale_y), body_scale, COLOR_TEXT, rumble_line);
    draw_text_centered(renderer, x + (w / 2), y + scale_value(206, scale_y), body_scale, COLOR_TEXT, trigger_line);
}

static void draw_scene(const AppState *app)
{
    SDL_Renderer *renderer = app->renderer;
    char banner[160];
    int width;
    int height;
    float scale_x;
    float scale_y;
    float unit_scale;
    int text_small;
    int text_medium;
    int text_stick;
    int controls_y_offset;
    int title_h;
    int status_h;
    int footer_h;
    int footer2_h;
    int upper_top;
    int upper_bottom;
    int footer_y;
    int left_panel_right;
    int right_panel_left;
    int trigger_w;
    int trigger_h;
    int small_button_w;
    int small_button_h;
    int top_circle_r;
    int stick_outer_r;
    int stick_inner_r;
    int stick_fill_r;
    int stick_motion_r;
    int stick_dot_r;
    int dpad_center;
    int dpad_arm;
    int dpad_gap;
    bool compact_layout;

    SDL_GetRendererOutputSize(renderer, &width, &height);
    scale_x = (float)width / (float)WINDOW_WIDTH;
    scale_y = (float)height / (float)WINDOW_HEIGHT;
    unit_scale = scale_x < scale_y ? scale_x : scale_y;
    compact_layout = width <= 800 && height <= 600;

    text_small = scale_font(2, unit_scale);
    text_medium = scale_font(3, unit_scale);
    text_stick = scale_font(5, unit_scale);
    controls_y_offset = compact_layout ? 0 : scale_value(18, scale_y);
    title_h = scale_value(compact_layout ? 36 : 44, scale_y);
    status_h = scale_value(compact_layout ? 36 : 44, scale_y);
    footer_h = scale_value(compact_layout ? 30 : 34, scale_y);
    footer2_h = scale_value(compact_layout ? 28 : 32, scale_y);
    upper_top = title_h + status_h;
    upper_bottom = scale_value(compact_layout ? 294 : 328, scale_y);
    footer_y = height - footer_h - footer2_h;
    left_panel_right = scale_value(430, scale_x);
    right_panel_left = scale_value(850, scale_x);
    trigger_w = scale_value(84, scale_x);
    trigger_h = scale_value(34, scale_y);
    small_button_w = scale_value(80, scale_x);
    small_button_h = scale_value(34, scale_y);
    top_circle_r = scale_value(34, unit_scale);
    stick_outer_r = scale_value(72, unit_scale);
    stick_inner_r = scale_value(40, unit_scale);
    stick_fill_r = scale_value(28, unit_scale);
    stick_dot_r = scale_value(9, unit_scale);
    stick_motion_r = stick_outer_r - stick_dot_r - scale_value(6, unit_scale);
    dpad_center = scale_value(34, unit_scale);
    dpad_arm = scale_value(34, unit_scale);
    dpad_gap = scale_value(4, unit_scale);

    if (app->controller != NULL) {
        char clean_name[96];

        sanitize_label(app->controller_name, clean_name, sizeof(clean_name));
        SDL_snprintf(banner, sizeof(banner), "CONNECTED: %s", clean_name[0] != '\0' ? clean_name : "UNKNOWN CONTROLLER");
    } else {
        SDL_strlcpy(banner, "THE CONTROLLER IS NOT CONNECTED OR CANNOT BE FOUND", sizeof(banner));
    }

    set_color(renderer, COLOR_BACKGROUND);
    SDL_RenderClear(renderer);

    fill_rect(renderer, 0, 0, width, title_h, COLOR_BAR);
    fill_rect(renderer, 0, title_h, width, status_h, COLOR_BAR_ALT);
    fill_rect(renderer, 0, footer_y, width, footer_h, COLOR_BAR);
    fill_rect(renderer, 0, footer_y + footer_h, width, footer2_h, COLOR_BAR_ALT);

    draw_hline(renderer, 0, width, upper_top, COLOR_LINE);
    draw_hline(renderer, 0, width, upper_bottom, COLOR_LINE);
    draw_vline(renderer, left_panel_right, upper_bottom, footer_y, COLOR_FAINT);
    draw_vline(renderer, right_panel_left, upper_bottom, footer_y, COLOR_FAINT);

    draw_text_centered(renderer, width / 2, scale_value(12, scale_y), text_small, COLOR_TEXT_INVERSE, "SDL2 CONTROLLER TEST");
    draw_text_centered(renderer, width / 2, title_h + scale_value(12, scale_y), text_small, COLOR_TEXT_INVERSE, banner);

    fill_rect(renderer, scale_value(24, scale_x), scale_value(116, scale_y) + controls_y_offset, scale_value(82, scale_x), scale_value(8, scale_y), COLOR_FAINT);
    fill_rect(renderer, width - scale_value(106, scale_x), scale_value(116, scale_y) + controls_y_offset, scale_value(82, scale_x), scale_value(8, scale_y), COLOR_FAINT);

    draw_trigger_box(
        renderer,
        scale_value(24, scale_x),
        scale_value(150, scale_y) + controls_y_offset,
        trigger_w,
        trigger_h,
        "L2",
        app->axes[SDL_CONTROLLER_AXIS_TRIGGERLEFT],
        text_small);
    draw_labeled_button(
        renderer,
        scale_value(24, scale_x),
        scale_value(206, scale_y) + controls_y_offset,
        trigger_w,
        trigger_h,
        "L1",
        app->buttons[SDL_CONTROLLER_BUTTON_LEFTSHOULDER] != 0,
        text_small);
    draw_dpad(
        renderer,
        scale_value(265, scale_x),
        scale_value(174, scale_y) + controls_y_offset,
        app,
        dpad_center,
        dpad_arm,
        dpad_center,
        dpad_gap);
    draw_labeled_circle(
        renderer,
        scale_value(470, scale_x),
        scale_value(194, scale_y) + controls_y_offset,
        top_circle_r,
        "L3",
        app->buttons[SDL_CONTROLLER_BUTTON_LEFTSTICK] != 0,
        text_small);

    draw_labeled_button(
        renderer,
        scale_value(540, scale_x),
        scale_value(142, scale_y) + controls_y_offset,
        small_button_w,
        small_button_h,
        "SELECT",
        app->buttons[SDL_CONTROLLER_BUTTON_BACK] != 0,
        text_small);
    draw_labeled_button(
        renderer,
        scale_value(660, scale_x),
        scale_value(142, scale_y) + controls_y_offset,
        small_button_w,
        small_button_h,
        "START",
        app->buttons[SDL_CONTROLLER_BUTTON_START] != 0,
        text_small);
    draw_labeled_circle(
        renderer,
        scale_value(640, scale_x),
        scale_value(238, scale_y) + controls_y_offset,
        top_circle_r,
        "MODE",
        app->buttons[SDL_CONTROLLER_BUTTON_GUIDE] != 0,
        text_small);

    draw_labeled_circle(
        renderer,
        scale_value(810, scale_x),
        scale_value(194, scale_y) + controls_y_offset,
        top_circle_r,
        "R3",
        app->buttons[SDL_CONTROLLER_BUTTON_RIGHTSTICK] != 0,
        text_small);
    draw_labeled_circle(
        renderer,
        scale_value(986, scale_x),
        scale_value(146, scale_y) + controls_y_offset,
        top_circle_r,
        "Y",
        app->buttons[SDL_CONTROLLER_BUTTON_Y] != 0,
        text_small);
    draw_labeled_circle(
        renderer,
        scale_value(1070, scale_x),
        scale_value(146, scale_y) + controls_y_offset,
        top_circle_r,
        "B",
        app->buttons[SDL_CONTROLLER_BUTTON_B] != 0,
        text_small);
    draw_labeled_circle(
        renderer,
        scale_value(944, scale_x),
        scale_value(234, scale_y) + controls_y_offset,
        top_circle_r,
        "X",
        app->buttons[SDL_CONTROLLER_BUTTON_X] != 0,
        text_small);
    draw_labeled_circle(
        renderer,
        scale_value(1028, scale_x),
        scale_value(234, scale_y) + controls_y_offset,
        top_circle_r,
        "A",
        app->buttons[SDL_CONTROLLER_BUTTON_A] != 0,
        text_small);

    draw_trigger_box(
        renderer,
        width - scale_value(108, scale_x),
        scale_value(150, scale_y) + controls_y_offset,
        trigger_w,
        trigger_h,
        "R2",
        app->axes[SDL_CONTROLLER_AXIS_TRIGGERRIGHT],
        text_small);
    draw_labeled_button(
        renderer,
        width - scale_value(108, scale_x),
        scale_value(206, scale_y) + controls_y_offset,
        trigger_w,
        trigger_h,
        "R1",
        app->buttons[SDL_CONTROLLER_BUTTON_RIGHTSHOULDER] != 0,
        text_small);

    draw_large_stick(
        renderer,
        left_panel_right / 2,
        scale_value(482, scale_y),
        "L",
        app->axes[SDL_CONTROLLER_AXIS_LEFTX],
        app->axes[SDL_CONTROLLER_AXIS_LEFTY],
        app->buttons[SDL_CONTROLLER_BUTTON_LEFTSTICK] != 0,
        stick_outer_r,
        stick_inner_r,
        stick_fill_r,
        stick_motion_r,
        stick_dot_r,
        text_stick);

    draw_large_stick(
        renderer,
        (right_panel_left + width) / 2,
        scale_value(482, scale_y),
        "R",
        app->axes[SDL_CONTROLLER_AXIS_RIGHTX],
        app->axes[SDL_CONTROLLER_AXIS_RIGHTY],
        app->buttons[SDL_CONTROLLER_BUTTON_RIGHTSTICK] != 0,
        stick_outer_r,
        stick_inner_r,
        stick_fill_r,
        stick_motion_r,
        stick_dot_r,
        text_stick);

    draw_details_panel(
        renderer,
        app,
        left_panel_right,
        upper_bottom,
        right_panel_left - left_panel_right,
        footer_y - upper_bottom,
        scale_y,
        text_medium,
        text_small);

    draw_text_centered(
        renderer,
        width / 2,
        footer_y + scale_value(10, scale_y),
        text_small,
        COLOR_TEXT_INVERSE,
        "A WEAK   B STRONG   X DUAL   Y TRIGGER");

    if (app->rumble_demo_enabled) {
        draw_text_centered(
            renderer,
            width / 2,
            footer_y + footer_h + scale_value(8, scale_y),
            text_small,
            COLOR_TEXT_INVERSE,
            "RUMBLE DEMO ACTIVE   BACK STOP   START+SELECT X2 QUIT");
    } else {
        draw_text_centered(
            renderer,
            width / 2,
            footer_y + footer_h + scale_value(8, scale_y),
            text_small,
            COLOR_TEXT_INVERSE,
            "START DEMO   BACK STOP   START+SELECT X2 QUIT");
    }

    SDL_RenderPresent(renderer);
}

static void stop_rumble(AppState *app)
{
    if (app->controller == NULL) {
        return;
    }

    SDL_GameControllerRumble(app->controller, 0, 0, 0);
    SDL_GameControllerRumbleTriggers(app->controller, 0, 0, 0);
    app->rumble_demo_enabled = false;
    set_status(app, "Rumble stopped on %s", app->controller_name);
}

static void run_rumble(AppState *app, Uint16 low, Uint16 high, Uint32 duration_ms, const char *label)
{
    if (app->controller == NULL) {
        set_status(app, "No controller connected");
        return;
    }

    if (!app->rumble_supported) {
        set_status(app, "Controller has no standard rumble support");
        return;
    }

    if (SDL_GameControllerRumble(app->controller, low, high, duration_ms) == 0) {
        app->rumble_demo_enabled = false;
        set_status(app, "%s: low=%u high=%u duration=%ums", label, low, high, duration_ms);
    } else {
        set_status(app, "%s failed: %s", label, SDL_GetError());
    }
}

static void run_trigger_rumble(AppState *app, Uint16 left, Uint16 right, Uint32 duration_ms)
{
    if (app->controller == NULL) {
        set_status(app, "No controller connected");
        return;
    }

    if (!app->trigger_rumble_supported) {
        set_status(app, "Controller has no trigger rumble support");
        return;
    }

    if (SDL_GameControllerRumbleTriggers(app->controller, left, right, duration_ms) == 0) {
        app->rumble_demo_enabled = false;
        set_status(app, "Trigger rumble: left=%u right=%u duration=%ums", left, right, duration_ms);
    } else {
        set_status(app, "Trigger rumble failed: %s", SDL_GetError());
    }
}

static void close_controller(AppState *app)
{
    if (app->controller == NULL) {
        return;
    }

    SDL_GameControllerClose(app->controller);
    app->controller = NULL;
    app->instance_id = -1;
    app->rumble_supported = false;
    app->trigger_rumble_supported = false;
    app->hat_state = 0;
    app->exit_combo_count = 0;
    app->last_exit_combo_tick = 0;
    SDL_memset(app->axes, 0, sizeof(app->axes));
    SDL_memset(app->buttons, 0, sizeof(app->buttons));
    reset_exit_combo_hold(app);
    SDL_strlcpy(app->controller_name, "No controller", sizeof(app->controller_name));
    SDL_strlcpy(app->last_input, "WAITING FOR INPUT", sizeof(app->last_input));
    set_status(app, "Controller disconnected, waiting for a new one");
}

static bool open_controller(AppState *app, int device_index)
{
    SDL_Joystick *joystick;

    if (!SDL_IsGameController(device_index)) {
        set_status(app, "Device %d is not recognized as an SDL game controller", device_index);
        return false;
    }

    app->controller = SDL_GameControllerOpen(device_index);
    if (app->controller == NULL) {
        set_status(app, "Failed to open controller %d: %s", device_index, SDL_GetError());
        return false;
    }

    joystick = SDL_GameControllerGetJoystick(app->controller);
    app->instance_id = SDL_JoystickInstanceID(joystick);
    app->rumble_supported = SDL_GameControllerHasRumble(app->controller) == SDL_TRUE;
    app->trigger_rumble_supported = SDL_GameControllerHasRumbleTriggers(app->controller) == SDL_TRUE;
    app->hat_state = 0;
    app->exit_combo_count = 0;
    app->last_exit_combo_tick = 0;
    SDL_memset(app->axes, 0, sizeof(app->axes));
    SDL_memset(app->buttons, 0, sizeof(app->buttons));
    reset_exit_combo_hold(app);
    SDL_strlcpy(
        app->controller_name,
        SDL_GameControllerName(app->controller) != NULL ? SDL_GameControllerName(app->controller) : "Unknown controller",
        sizeof(app->controller_name));
    SDL_strlcpy(app->last_input, "WAITING FOR INPUT", sizeof(app->last_input));
    app->last_demo_tick = SDL_GetTicks();

    set_status(
        app,
        "Connected: %s | rumble=%s trigger_rumble=%s",
        app->controller_name,
        app->rumble_supported ? "yes" : "no",
        app->trigger_rumble_supported ? "yes" : "no");
    return true;
}

static bool open_first_controller(AppState *app)
{
    int count = SDL_NumJoysticks();

    for (int i = 0; i < count; ++i) {
        if (SDL_IsGameController(i)) {
            return open_controller(app, i);
        }
    }

    set_status(app, "No controller found, plug one in and SDL will hotplug it");
    return false;
}

static void update_rumble_demo(AppState *app)
{
    Uint32 now;
    Uint32 phase;
    Uint16 low;
    Uint16 high;

    if (!app->rumble_demo_enabled || app->controller == NULL || !app->rumble_supported) {
        return;
    }

    now = SDL_GetTicks();
    if (now - app->last_demo_tick < 100) {
        return;
    }

    phase = (now / 250) % 4;
    switch (phase) {
        case 0:
            low = 0x3000;
            high = 0x0000;
            break;
        case 1:
            low = 0x7000;
            high = 0x1000;
            break;
        case 2:
            low = 0x2000;
            high = 0x7000;
            break;
        default:
            low = 0x9000;
            high = 0xffff;
            break;
    }

    if (SDL_GameControllerRumble(app->controller, low, high, 180) != 0) {
        set_status(app, "Rumble demo stopped: %s", SDL_GetError());
        app->rumble_demo_enabled = false;
        return;
    }

    app->last_demo_tick = now;
}

static void print_help(void)
{
    SDL_Log("SDL2 controller test started");
    SDL_Log("Controls:");
    SDL_Log("  A     -> weak rumble");
    SDL_Log("  B     -> strong rumble");
    SDL_Log("  X     -> dual motor rumble");
    SDL_Log("  Y     -> trigger rumble");
    SDL_Log("  START -> toggle rumble demo");
    SDL_Log("  BACK  -> stop all rumble");
    SDL_Log("  START + BACK twice -> quit");
}

int main(int argc, char **argv)
{
    AppState app;
    SDL_Event event;
    bool running = true;

    (void)argc;
    (void)argv;

    SDL_SetMainReady();
    SDL_memset(&app, 0, sizeof(app));
    app.instance_id = -1;
    SDL_strlcpy(app.controller_name, "No controller", sizeof(app.controller_name));
    SDL_strlcpy(app.status_line, "Starting", sizeof(app.status_line));
    SDL_strlcpy(app.last_input, "WAITING FOR INPUT", sizeof(app.last_input));

    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_EVENTS) != 0) {
        fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }

    SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");

    app.window = SDL_CreateWindow(
        "SDL2 Controller Test",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE | SDL_WINDOW_FULLSCREEN_DESKTOP);
    if (app.window == NULL) {
        fprintf(stderr, "SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    app.renderer = SDL_CreateRenderer(app.window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (app.renderer == NULL) {
        SDL_Log("Accelerated renderer unavailable, falling back to software: %s", SDL_GetError());
        app.renderer = SDL_CreateRenderer(app.window, -1, SDL_RENDERER_SOFTWARE);
        if (app.renderer == NULL) {
            fprintf(stderr, "SDL_CreateRenderer failed: %s\n", SDL_GetError());
            SDL_DestroyWindow(app.window);
            SDL_Quit();
            return 1;
        }
    }
    print_help();
    open_first_controller(&app);

    while (running) {
        while (SDL_PollEvent(&event) == 1) {
            switch (event.type) {
                case SDL_QUIT:
                    running = false;
                    break;

                case SDL_CONTROLLERDEVICEADDED:
                    if (app.controller == NULL) {
                        open_controller(&app, event.cdevice.which);
                    }
                    break;

                case SDL_CONTROLLERDEVICEREMOVED:
                    if (event.cdevice.which == app.instance_id) {
                        close_controller(&app);
                        open_first_controller(&app);
                    }
                    break;

                case SDL_CONTROLLERAXISMOTION:
                    if (event.caxis.which == app.instance_id &&
                        event.caxis.axis < SDL_CONTROLLER_AXIS_MAX) {
                        app.axes[event.caxis.axis] = event.caxis.value;
                        if ((event.caxis.axis == SDL_CONTROLLER_AXIS_TRIGGERLEFT || event.caxis.axis == SDL_CONTROLLER_AXIS_TRIGGERRIGHT) ?
                            normalized_trigger(event.caxis.value) > 0.05f :
                            filtered_axis(event.caxis.value) != 0) {
                            remember_axis_event(&app, event.caxis.axis, event.caxis.value);
                        }
                    }
                    break;

                case SDL_CONTROLLERBUTTONDOWN:
                    if (event.cbutton.which == app.instance_id &&
                        event.cbutton.button < SDL_CONTROLLER_BUTTON_MAX) {
                        app.buttons[event.cbutton.button] = 1;
                        remember_button_event(&app, event.cbutton.button);

                        switch (event.cbutton.button) {
                            case SDL_CONTROLLER_BUTTON_A:
                                run_rumble(&app, 0x7000, 0x0000, 350, "Weak rumble");
                                break;
                            case SDL_CONTROLLER_BUTTON_B:
                                run_rumble(&app, 0x0000, 0xffff, 350, "Strong rumble");
                                break;
                            case SDL_CONTROLLER_BUTTON_X:
                                run_rumble(&app, 0xc000, 0xc000, 700, "Dual motor rumble");
                                break;
                            case SDL_CONTROLLER_BUTTON_Y:
                                run_trigger_rumble(&app, 0xffff, 0xffff, 700);
                                break;
                            case SDL_CONTROLLER_BUTTON_START:
                            case SDL_CONTROLLER_BUTTON_BACK:
                                if (app.buttons[SDL_CONTROLLER_BUTTON_START] != 0 &&
                                    app.buttons[SDL_CONTROLLER_BUTTON_BACK] != 0 &&
                                    !app.exit_combo_held) {
                                    if (register_exit_combo(&app)) {
                                        running = false;
                                    }
                                }
                                break;
                            default:
                                break;
                        }
                    }
                    break;

                case SDL_CONTROLLERBUTTONUP:
                    if (event.cbutton.which == app.instance_id &&
                        event.cbutton.button < SDL_CONTROLLER_BUTTON_MAX) {
                        bool suppress_release = false;

                        if (event.cbutton.button == SDL_CONTROLLER_BUTTON_BACK) {
                            suppress_release = app.suppress_back_release;
                        } else if (event.cbutton.button == SDL_CONTROLLER_BUTTON_START) {
                            suppress_release = app.suppress_start_release;
                        }

                        app.buttons[event.cbutton.button] = 0;

                        if (event.cbutton.button == SDL_CONTROLLER_BUTTON_BACK && !suppress_release) {
                            stop_rumble(&app);
                        } else if (event.cbutton.button == SDL_CONTROLLER_BUTTON_START && !suppress_release) {
                            toggle_rumble_demo(&app);
                        }

                        if (app.buttons[SDL_CONTROLLER_BUTTON_BACK] == 0 &&
                            app.buttons[SDL_CONTROLLER_BUTTON_START] == 0) {
                            reset_exit_combo_hold(&app);
                        }
                    }
                    break;

                case SDL_JOYHATMOTION:
                    if (event.jhat.which == app.instance_id) {
                        app.hat_state = event.jhat.value;
                        if ((event.jhat.value & SDL_HAT_UP) != 0) {
                            SDL_strlcpy(app.last_input, "DPAD UP", sizeof(app.last_input));
                        } else if ((event.jhat.value & SDL_HAT_DOWN) != 0) {
                            SDL_strlcpy(app.last_input, "DPAD DOWN", sizeof(app.last_input));
                        } else if ((event.jhat.value & SDL_HAT_LEFT) != 0) {
                            SDL_strlcpy(app.last_input, "DPAD LEFT", sizeof(app.last_input));
                        } else if ((event.jhat.value & SDL_HAT_RIGHT) != 0) {
                            SDL_strlcpy(app.last_input, "DPAD RIGHT", sizeof(app.last_input));
                        }
                    }
                    break;

                default:
                    break;
            }
        }

        update_rumble_demo(&app);
        draw_scene(&app);
    }

    stop_rumble(&app);
    close_controller(&app);
    SDL_DestroyRenderer(app.renderer);
    SDL_DestroyWindow(app.window);
    SDL_Quit();
    return 0;
}

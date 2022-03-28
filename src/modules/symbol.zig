const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");

pub const module = mod.Module{ .name = "symbol", .print = print };

fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
    const symbol_style = term.Style{
        .foreground = term.Color.Green,
        .font_style = term.FontStyle.bold,
    };

    try term.updateStyle(writer, symbol_style, ctx.last_style);
    ctx.last_style = symbol_style;
    try writer.writeAll(" >> ");
}

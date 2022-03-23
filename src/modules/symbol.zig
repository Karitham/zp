const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");

pub const module = mod.Module{
    .name = "symbol",
    .print = struct {
        fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
            const symbol_style = term.Style{
                .foreground = term.Color.Green,
                .font_style = term.FontStyle.bold,
            };

            try term.updateStyle(writer, symbol_style, ctx.last_style);
            ctx.last_style = symbol_style;
            try writer.writeAll(" >> ");
        }
    }.print,
};

fn splitPath(path: []u8) []const u8 {
    const it = std.mem.lastIndexOf(u8, path, "/");
    if (it) |it1| {
        const it2 = std.mem.lastIndexOf(u8, path[0..it1], "/");
        if (it2) |it3| {
            return path[it3..];
        }
        return path[it1..];
    }
    return path;
}

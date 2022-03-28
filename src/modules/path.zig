const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");

pub const module = mod.Module{ .name = "path", .print = print };

fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
    const path_style = term.Style{
        .foreground = term.Color.Cyan,
        .font_style = term.FontStyle.bold,
    };

    var buf: [512]u8 = undefined;
    var pwd = try std.os.getcwd(&buf);

    try term.updateStyle(writer, path_style, ctx.last_style);
    ctx.last_style = path_style;

    try writer.print(".{s}", .{splitPath(pwd)});
}

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

const std = @import("std");
const term = @import("ansi-term");
const Module = @import("../module.zig").Module;

pub const module = Module{
    .name = "path",
    .print = struct {
        fn print(writer: anytype, old: ?term.Style) ?term.Style {
            const path_style = term.Style{
                .foreground = term.Color.Cyan,
                .font_style = term.FontStyle.bold,
            };

            var buf: [512]u8 = undefined;
            var pwd = std.os.getcwd(&buf) catch return old;
            term.updateStyle(writer, path_style, old) catch return old;
            writer.print(".{s}", .{splitPath(pwd)}) catch return path_style;
            return path_style;
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

const std = @import("std");
const term = @import("ansi-term");
const utils = @import("../utils.zig");
const mod = @import("../module.zig");

pub const module = mod.Module{
    .name = "go",
    .print = struct {
        fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
            var cwd = try std.fs.cwd().openDir(".", .{ .iterate = true });
            defer cwd.close();

            if (!try utils.containsAnyGlob(ctx.alloc, cwd, &.{ "go.mod", "*.go" })) return;

            const go_style = term.Style{
                .foreground = term.Color.Blue,
                .font_style = term.FontStyle.bold,
            };

            if (try getGoVersion(ctx.alloc)) |zv| {
                try term.updateStyle(writer, go_style, ctx.last_style);
                ctx.last_style = go_style;
                try writer.print(" 🐹 {s}", .{zv});
            }
        }
    }.print,
};

fn getGoVersion(alloc: std.mem.Allocator) !?[]const u8 {
    var proc = try std.ChildProcess.init(&.{ "go", "version" }, alloc);
    defer proc.deinit();

    proc.stdout_behavior = .Pipe;

    try proc.spawn();
    if (proc.stdout) |stdout| {
        var big_buf: [4096]u8 = undefined;
        if (try stdout.reader().readUntilDelimiterOrEof(&big_buf, '\n')) |buf| {
            _ = proc.wait() catch return null;

            const start_ind = std.mem.indexOf(u8, buf[0..], "go1.");
            const ind = std.mem.indexOfPos(u8, buf[0..], start_ind.?, " ");
            if (ind) |i| return buf[start_ind.?..i];
            return buf[start_ind.?..];
        }
    }

    _ = try proc.kill();
    return null;
}

test "get go version" {
    const v = getGoVersion(std.testing.allocator) catch null;
    std.debug.assert(v != null);
}

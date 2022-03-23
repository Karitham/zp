const std = @import("std");
const term = @import("ansi-term");
const utils = @import("../utils.zig");
const mod = @import("../module.zig");

pub const module = mod.Module{
    .name = "zig",
    .print = struct {
        fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
            var cwd = try std.fs.cwd().openDir(".", .{ .iterate = true });
            defer cwd.close();

            const contains_file = try utils.containsAnyGlob(ctx.alloc, cwd, &.{"*.zig"});
            if (!contains_file) return;

            const zig_style = term.Style{
                .foreground = term.Color.Yellow,
                .font_style = term.FontStyle.bold,
            };

            if (try getZigVersion(ctx.alloc)) |v| {
                defer ctx.alloc.free(v);
                try term.updateStyle(writer, zig_style, ctx.last_style);
                ctx.last_style = zig_style;
                try writer.print(" ⚡️{s}", .{v});
            }
        }
    }.print,
};

/// Returns the version of zig if in path.
/// Caller owns returned memory.
fn getZigVersion(alloc: std.mem.Allocator) !?[]const u8 {
    var proc = try std.ChildProcess.init(&.{ "zig", "version" }, alloc);
    defer proc.deinit();

    proc.stdout_behavior = .Pipe;

    try proc.spawn();
    if (proc.stdout) |stdout| {
        var big_buf: [2 * 1024]u8 = undefined;
        if (try stdout.reader().readUntilDelimiterOrEof(&big_buf, '\n')) |buf| {
            _ = proc.wait() catch return null;

            var it = std.mem.split(u8, buf, ".");
            _ = it.next();
            _ = it.next();
            _ = it.next();

            return try alloc.dupe(u8, buf[0 .. it.index.? - 1]);
        }
    }

    _ = try proc.kill();
    return null;
}

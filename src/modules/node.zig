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

            if (!try utils.containsAnyGlob(ctx.alloc, cwd, &.{ "package.json", "*.js", "*.ts", "*.jsx", "*.tsx" })) return;

            const node_style = term.Style{
                .foreground = term.Color.Green,
                .font_style = term.FontStyle.bold,
            };

            if (try getNodeVersion(ctx.alloc)) |zv| {
                try term.updateStyle(writer, node_style, ctx.last_style);
                ctx.last_style = node_style;
                try writer.print(" 🟩 {s}", .{zv});
            }
        }
    }.print,
};

fn getNodeVersion(alloc: std.mem.Allocator) !?[]const u8 {
    var proc = try std.ChildProcess.init(&.{ "node", "--version" }, alloc);
    defer proc.deinit();

    proc.stdout_behavior = .Pipe;

    try proc.spawn();
    if (proc.stdout) |stdout| {
        var big_buf: [4096]u8 = undefined;
        if (try stdout.reader().readUntilDelimiterOrEof(&big_buf, '\n')) |buf| {
            _ = proc.wait() catch return null;
            return buf;
        }
    }

    _ = try proc.kill();
    return null;
}

test "get node version" {
    const v = getNodeVersion(std.testing.allocator) catch null;
    std.debug.assert(v != null);
}

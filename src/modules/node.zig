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

            if (try getNodeVersion(ctx.alloc)) |v| {
                defer ctx.alloc.free(v);
                try term.updateStyle(writer, node_style, ctx.last_style);
                ctx.last_style = node_style;
                try writer.print(" 🟩 {s}", .{v});
            }
        }
    }.print,
};

/// Returns the version of node if in path.
/// Caller owns returned memory.
fn getNodeVersion(alloc: std.mem.Allocator) !?[]const u8 {
    var proc = try std.ChildProcess.init(&.{ "node", "--version" }, alloc);
    defer proc.deinit();

    proc.stdout_behavior = .Pipe;

    try proc.spawn();
    if (proc.stdout) |stdout| {
        var big_buf: [512]u8 = undefined;
        if (try stdout.reader().readUntilDelimiterOrEof(&big_buf, '\n')) |buf| {
            _ = proc.wait() catch return null;
            return try alloc.dupe(u8, buf);
        }
    }

    _ = try proc.kill();
    return null;
}

test "get node version" {
    const v = getNodeVersion(std.testing.allocator) catch null;
    try std.testing.expect(v != null);
    defer std.testing.allocator.free(v.?);
}

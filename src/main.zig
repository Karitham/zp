const std = @import("std");
const mod = @import("module.zig");
const term = @import("ansi-term");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var argIt = try std.process.argsWithAllocator(gpa.allocator());
    defer argIt.deinit();

    const progName = argIt.next();
    while (argIt.next()) |arg| {
        if (std.mem.eql(u8, "prompt", arg))
            return drawPrompt(gpa.allocator())
        else if (std.mem.eql(u8, "hook", arg))
            return zshHook()
        else
            return std.io.getStdErr().writer().print("Unknown command: {s}\n", .{arg});
    }

    return std.io.getStdErr().writer().print(
        \\Usage: {s} <command>
        \\Commands:
        \\    prompt - display prompt
        \\    hook - hook into zsh
        \\
    , .{progName.?});
}

fn zshHook() !void {
    const hook = @embedFile("hooks/hook.zsh");
    try std.io.getStdOut().writeAll(hook);
}

fn drawPrompt(alloc: std.mem.Allocator) !void {
    var out_buf: [2 * 1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&out_buf);
    try prompt(fbs.writer(), alloc, mod.enabled);
    try std.io.getStdOut().writeAll(fbs.getWritten());
}

fn prompt(writer: anytype, alloc: std.mem.Allocator, m: []const mod.Module) !void {
    var ctx = mod.Context.init(alloc);

    inline for (m) |mo| mo.print(writer, &ctx) catch {};
    try term.updateStyle(writer, term.Style{}, ctx.last_style);
}

test "bench" {
    if (std.os.getenv("BENCH") == null) return;

    const time = std.time;
    const run_count = 2000;

    var buf = std.ArrayList(u8).init(std.testing.allocator);
    try buf.ensureTotalCapacity(2048);
    defer buf.deinit();

    const start = time.milliTimestamp();
    var i: usize = 0;
    while (i < run_count) : (i += 1) {
        defer buf.clearRetainingCapacity();
        try prompt(buf.writer(), std.testing.allocator, mod.enabled);
    }
    const end = time.milliTimestamp();
    std.debug.print(
        "took {} ms for {} runs, avg: {d} ms/run\n",
        .{
            end - start,
            run_count,
            @intToFloat(f64, end - start) / @intToFloat(f64, run_count),
        },
    );
}

test "tests" {
    _ = @import("module.zig");
    _ = @import("utils.zig");
}

const std = @import("std");
const glob = @import("glob");

pub fn containsAnyGlob(alloc: std.mem.Allocator, root: std.fs.Dir, patterns: []const []const u8) !bool {
    for (patterns) |p| {
        var it = try glob.Iterator.init(alloc, root, p);
        defer it.deinit();

        if ((try it.next()) != null) return true;
    }
    return false;
}

test "containsAny" {
    var cwd = try std.fs.cwd().openDir(".", .{ .iterate = true });
    defer cwd.close();

    var buf_a: [1024 * 256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf_a);

    const v = try containsAnyGlob(fba.allocator(), cwd, &.{"*.zig"});
    try std.testing.expect(v);
}

const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");
const git = @import("zig-libgit2");

pub const module = mod.Module{ .name = "git", .print = print };

fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
    const git_style = term.Style{
        .foreground = term.Color.Magenta,
        .font_style = term.FontStyle.bold,
    };

    var git_meta = try GitMetadata.init(ctx.alloc);
    defer git_meta.deinit();

    if (git_meta.branch() catch null) |branch| {
        defer ctx.alloc.free(branch);
        try term.updateStyle(writer, git_style, ctx.last_style);
        ctx.last_style = git_style;
        try writer.print("  {s}", .{branch});
    }
}

const GitMetadata = struct {
    repo: *git.Repository,
    handle: git.Handle,
    alloc: std.mem.Allocator,

    fn init(alloc: std.mem.Allocator) !GitMetadata {
        const handle = try git.init();
        return GitMetadata{
            .alloc = alloc,
            .handle = handle,
            .repo = try handle.repositoryOpenExtended("./", .{}, "/"),
        };
    }

    /// Caller owns the returned memory
    fn branch(gm: *GitMetadata) !?[]u8 {
        var head = try gm.repo.head();
        defer head.deinit();

        const name = try head.nameGet();
        return try gm.alloc.dupe(u8, name);
    }

    fn deinit(gm: *GitMetadata) void {
        gm.handle.deinit();
        gm.repo.deinit();
    }
};

test "git branch" {
    const expect = std.testing.expect;
    var git_meta = try GitMetadata.init(std.testing.allocator);
    defer git_meta.deinit();
    if (try git_meta.branch()) |branch| {
        defer std.testing.allocator.free(branch);
        try expect(branch.len > 2);
        // try std.testing.expectEqualSlices(u8, "master", branch);
    }
}

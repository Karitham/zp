const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");
const git = @import("zig-libgit2");

pub const module = mod.Module{
    .name = "git",
    .print = struct {
        fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
            const git_style = term.Style{
                .foreground = term.Color.Magenta,
                .font_style = term.FontStyle.bold,
            };

            var git_meta = try GitMetadata.init(ctx.alloc);
            defer git_meta.deinit();

            if (git_meta.branch_name) |branch| {
                try term.updateStyle(writer, git_style, ctx.last_style);
                ctx.last_style = git_style;
                try writer.print("  {s}", .{branch});
            }
        }
    }.print,
};

const GitMetadata = struct {
    branch_name: ?[]u8 = null,

    alloc: std.mem.Allocator,

    fn init(alloc: std.mem.Allocator) !GitMetadata {
        var gm: GitMetadata = GitMetadata{
            .alloc = alloc,
        };

        const handle = try git.init();
        defer handle.deinit();

        var repo: *git.Repository = try handle.repositoryOpenExtended("./", .{}, "/");
        defer repo.deinit();

        var head = try repo.head();
        defer head.deinit();

        const name = try head.nameGet();
        gm.branch_name = try alloc.dupe(u8, name);

        return gm;
    }

    inline fn deinit(gm: GitMetadata) void {
        if (gm.branch_name) |branch| {
            gm.alloc.free(branch);
        }
    }
};

test "git branch" {
    const expect = std.testing.expect;
    var git_meta = try GitMetadata.init(std.testing.allocator);
    defer git_meta.deinit();

    try expect(git_meta.branch_name != null);
    try expect(git_meta.branch_name.?.len > 2);
    // try std.testing.expectEqualSlices(u8, "master", branch.?);
}

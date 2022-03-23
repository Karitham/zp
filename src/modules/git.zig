const std = @import("std");
const term = @import("ansi-term");
const mod = @import("../module.zig");

pub const module = mod.Module{
    .name = "git",
    .print = struct {
        fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
            const git_style = term.Style{
                .foreground = term.Color.Magenta,
                .font_style = term.FontStyle.bold,
            };
            var buf: [1024]u8 = undefined;
            if (gitBranch(std.fs.cwd(), &buf)) |branch| {
                try term.updateStyle(writer, git_style, ctx.last_style);
                ctx.last_style = git_style;
                try writer.print("  {s}", .{branch});
            }
        }
    }.print,
};

fn gitBranch(d: std.fs.Dir, buf: []u8) ?[]u8 {
    const f = d.openFile(".git/HEAD", .{}) catch |err| {
        if (err == std.fs.File.OpenError.FileNotFound) {
            // HACK: We don't want to recurse in root. Haven't found a better way.
            var is_root: [1]u8 = undefined;
            if (std.mem.eql(u8, d.realpath(".", &is_root) catch "", "/")) return null;

            var nd = d.openDir("..", .{}) catch return null;
            defer nd.close();
            return gitBranch(nd, buf);
        }
        return null;
    };
    defer f.close();

    if (f.reader().readUntilDelimiterOrEof(buf, '\n') catch return null) |b| {
        if (std.mem.startsWith(u8, b, "ref: refs/heads/")) {
            return b[16..b.len];
        }
    }

    return null;
}

test "git branch" {
    const expect = std.testing.expect;

    var buf: [1024]u8 = undefined;
    const branch = gitBranch(std.fs.cwd(), &buf);
    try expect(branch != null);
    try expect(branch.?.len > 2);
    // try std.testing.expectEqualSlices(u8, "master", branch.?);

    // ensure we don't crash by recursively checking for .git folders
    var root = try std.fs.openDirAbsolute("/dev", .{});
    defer root.close();
    try expect(gitBranch(root, &buf) == null);
}

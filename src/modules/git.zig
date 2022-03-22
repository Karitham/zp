const std = @import("std");
const term = @import("ansi-term");
const Module = @import("../module.zig").Module;

pub const module = Module{
    .name = "git",
    .print = struct {
        fn print(writer: anytype, old: ?term.Style) ?term.Style {
            if (gitBranch(std.fs.cwd())) |branch| {
                const git_style = term.Style{
                    .foreground = term.Color.Magenta,
                    .font_style = term.FontStyle.bold,
                };
                term.updateStyle(writer, term.Style{}, old) catch return old;
                writer.writeAll(" on ") catch return term.Style{};
                term.updateStyle(writer, git_style, term.Style{}) catch return term.Style{};
                writer.print(" {s}", .{branch}) catch return git_style;
            }
            return null;
        }
    }.print,
};

fn gitBranch(d: std.fs.Dir) ?[]u8 {
    const f = d.openFile(".git/HEAD", .{}) catch |err| {
        if (err == std.fs.File.OpenError.FileNotFound) {
            // HACK: We don't want to recurse in root. Haven't found a better way.
            var is_root: [1]u8 = undefined;
            if (std.mem.eql(u8, d.realpath(".", &is_root) catch "", "/")) return null;

            var nd = d.openDir("..", .{}) catch return null;
            defer nd.close();
            return gitBranch(nd);
        }
        return null;
    };
    defer f.close();

    var buf: [1024]u8 = undefined;
    const size = f.readAll(&buf) catch return null;
    if (std.mem.startsWith(u8, buf[0..size], "ref: refs/heads/")) return buf[16 .. size - 1]; //newline

    return null;
}

test "git branch" {
    const expect = std.testing.expect;

    const branch = gitBranch(std.fs.cwd());
    try expect(branch != null);
    try expect(branch.?.len > 2);

    // ensure we don't crash by recursively checking for .git folders
    var root = try std.fs.openDirAbsolute("/dev", .{});
    defer root.close();
    try expect(gitBranch(root) == null);
}

const std = @import("std");
const git = @import("modules/git.zig");
const path = @import("modules/path.zig");
const symbol = @import("modules/symbol.zig");
const term = @import("ansi-term");

pub const Module = struct {
    name: []const u8,
    print: fn (writer: anytype, old: ?term.Style) ?term.Style,
};

pub const enabled: []const Module = &.{
    path.module,
    git.module,
    symbol.module,
};

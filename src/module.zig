const std = @import("std");
const git = @import("modules/git.zig");
const path = @import("modules/path.zig");
const zig = @import("modules/zig.zig");
const go = @import("modules/go.zig");
const node = @import("modules/node.zig");
const symbol = @import("modules/symbol.zig");
const term = @import("ansi-term");

pub const enabled = &.{
    path.module,
    zig.module,
    go.module,
    node.module,
    git.module,
    symbol.module,
};

pub const Context = struct {
    last_style: ?term.Style = null,
    alloc: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) Context {
        return Context{
            .alloc = alloc,
        };
    }
};

pub const Module = struct {
    name: []const u8,
    print: fn (anytype, *Context) anyerror!void,
};

test "tests" {
    _ = @import("modules/git.zig");
    _ = @import("modules/go.zig");
    _ = @import("modules/node.zig");
    _ = @import("modules/zig.zig");
    _ = @import("modules/path.zig");
    _ = @import("modules/symbol.zig");
}

const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;

pub const pkgs = struct {
    pub const @"ansi-term" = Pkg{
        .name = "ansi-term",
        .path = FileSource{
            .path = ".gyro/ansi-term-ziglibs-github.com-c0f0ee3d/pkg/src/main.zig",
        },
    };

    pub const glob = Pkg{
        .name = "glob",
        .path = FileSource{
            .path = ".gyro/glob-mattnite-github.com-7d17d551/pkg/src/main.zig",
        },
    };

    pub const @"zig-libgit2" = Pkg{
        .name = "zig-libgit2",
        .path = FileSource{
            .path = ".gyro/zig-libgit2-leecannon-github.com-ff363b86/pkg/src/git.zig",
        },
    };

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        artifact.addPackage(pkgs.@"ansi-term");
        artifact.addPackage(pkgs.glob);
        artifact.addPackage(pkgs.@"zig-libgit2");
    }
};

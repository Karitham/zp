const std = @import("std");
const Pkg = std.build.Pkg;
const FileSource = std.build.FileSource;

pub const pkgs = struct {
    pub const @"ansi-term" = Pkg{
        .name = "ansi-term",
        .source = FileSource{
            .path = ".gyro/ansi-term-ziglibs-github.com-c0f0ee3d/pkg/src/main.zig",
        },
    };

    pub const glob = Pkg{
        .name = "glob",
        .source = FileSource{
            .path = ".gyro/glob-mattnite-github.com-7d17d551/pkg/src/main.zig",
        },
    };

    pub const @"zig-libgit2" = Pkg{
        .name = "zig-libgit2",
        .source = FileSource{
            .path = ".gyro/zig-libgit2-leecannon-github.com-ff363b86/pkg/src/git.zig",
        },
    };

    pub const libgit2 = Pkg{
        .name = "libgit2",
        .source = FileSource{
            .path = ".gyro/zig-libgit2-mattnite-github.com-0537beea/pkg/libgit2.zig",
        },
    };

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        artifact.addPackage(pkgs.@"ansi-term");
        artifact.addPackage(pkgs.glob);
        artifact.addPackage(pkgs.@"zig-libgit2");
        artifact.addPackage(pkgs.libgit2);
    }
};

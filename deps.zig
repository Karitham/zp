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

    pub fn addAllTo(artifact: *std.build.LibExeObjStep) void {
        artifact.addPackage(pkgs.@"ansi-term");
        artifact.addPackage(pkgs.glob);
    }
};

const std = @import("std");

pub fn build(b: *std.Build) void {
    const bin = b.addExecutable(.{
        .name = "foo", 
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
            .link_libc = true,
        }),
    });
    b.installArtifact(bin);

    bin.addIncludePath(b.path("include"));
    bin.addLibraryPath(b.path("include"));
    bin.addObjectFile(b.path("include/async.a"));

    const run_bin = b.addRunArtifact(bin);
    if (b.args) |args| {
        run_bin.addArgs(args);
    }
    const run_step = b.step("run", "run the binary");
    run_step.dependOn(&run_bin.step);
}

const std = @import("std");
const Step = std.build.Step;
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    var lib = b.addExecutable("obj-zig", "src/main.zig");
    lib.setBuildMode(mode);

    b.default_step.dependOn(&lib.step);
    b.installArtifact(lib);

    //Making it a exe for easy testing
    const run = b.step("run", "Run the tool");
    const lib_run = lib.run();
    lib_run.step.dependOn(b.getInstallStep());
    run.dependOn(&lib_run.step);
}

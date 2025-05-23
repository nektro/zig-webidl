const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    const options = b.addOptions();
    options.addOption([]const u8, "webidl2_path", deps.dirs._w0j5achmwzgf);

    {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("test.zig"),
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(unit_tests);
        unit_tests.root_module.addImport("build_options", options.createModule());
        unit_tests.use_llvm = !disable_llvm;
        unit_tests.use_lld = !disable_llvm;

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.has_side_effects = true;

        const test_step = b.step("test", "Run all library tests");
        test_step.dependOn(&run_unit_tests.step);
    }

    {
        const exe = b.addExecutable(.{
            .name = "webidl-playground",
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = mode,
        });
        deps.addAllTo(exe);
        exe.use_llvm = !disable_llvm;
        exe.use_lld = !disable_llvm;

        const run_cmd = b.addRunArtifact(exe);

        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }
}

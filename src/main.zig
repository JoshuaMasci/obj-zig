const std = @import("std");

const obj = @import("lib.zig");

//TODO: allow any filepath to be put in?
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) std.debug.panic("Error: memory leaked", .{});
    }

    var args_it = std.process.args();
    var at_end: bool = args_it.skip(); //skip excutable
    var file_name = try args_it.next(&gpa.allocator).?;
    defer gpa.allocator.free(file_name);

    std.log.info("Testing Objloader on file: {s}", .{file_name});

    var file = try std.fs.cwd().openFile(file_name, std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var reader = file.reader();

    var before = std.time.milliTimestamp();
    var mesh = try obj.parseObjFile(&gpa.allocator, reader, .{});
    var after = std.time.milliTimestamp();
    std.log.info("Parsing Took: {}ms", .{after - before});

    defer mesh.deinit();
}

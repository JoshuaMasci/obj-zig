const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("test_cube.obj", std.fs.File.OpenFlags{ .read = true });
    defer file.close();

    var reader = file.reader();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) std.debug.panic("Error: memory leaked", .{});
    }

    try loadObj(&gpa.allocator, reader, .{});
}

pub const Config = struct {};

pub fn loadObj(
    allocator: *std.mem.Allocator,
    reader: anytype,
    comptime config: Config,
) !void {
    var buffer: [1024]u8 = undefined;

    var vertex_positions = std.ArrayList([3]f32).init(allocator);
    defer vertex_positions.deinit();

    var vertex_normals = std.ArrayList([3]f32).init(allocator);
    defer vertex_normals.deinit();

    var vertex_uvs = std.ArrayList([2]f32).init(allocator);
    defer vertex_uvs.deinit();

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_white_space| {
        var line = std.mem.trimLeft(u8, line_with_white_space, " \t");

        //Filter out comments
        if (line[0] != '#') {
            var line_split = std.mem.tokenize(line, " ");
            var op = line_split.next().?;
            //std.log.info("{s}.{}", .{ op, op.len });
            if (std.mem.eql(u8, op, "o")) {
                std.log.info("Object: {s}", .{line_split.next().?});
            } else if (std.mem.eql(u8, op, "v")) {
                var value1 = try std.fmt.parseFloat(f32, line_split.next().?);
                var value2 = try std.fmt.parseFloat(f32, line_split.next().?);
                var value3 = try std.fmt.parseFloat(f32, line_split.next().?);
                try vertex_positions.append([3]f32{ value1, value2, value3 });
            } else if (std.mem.eql(u8, op, "vn")) {
                var value1 = try std.fmt.parseFloat(f32, line_split.next().?);
                var value2 = try std.fmt.parseFloat(f32, line_split.next().?);
                var value3 = try std.fmt.parseFloat(f32, line_split.next().?);
                try vertex_normals.append([3]f32{ value1, value2, value3 });
            } else if (std.mem.eql(u8, op, "vt")) {
                var value1 = try std.fmt.parseFloat(f32, line_split.next().?);
                var value2 = try std.fmt.parseFloat(f32, line_split.next().?);
                try vertex_uvs.append([2]f32{ value1, value2 });
            }
        }
    }

    std.log.info("Positions: {}", .{vertex_positions.items.len});
    std.log.info("Normals: {}", .{vertex_normals.items.len});
    std.log.info("Uvs: {}", .{vertex_uvs.items.len});
}

pub fn hello_lib() void {
    std.log.info("Hello From Library!", .{});
}

test "Test Test" {
    try hello_lib();
}

const std = @import("std");
const compressor = @import("compressor.zig");
const types = @import("types.zig");

const compression_types = [_]types.Compression {
    .zlib,
    .gzip,
    .brotli,
    .none,
}; 

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    const input = "foo bar baz";
    for (compression_types) |t| {
        try print("\x1b[1mcompressing into \x1b[0;32m{s}\x1b[0m\n", .{@tagName(t)});
        
        const res = try compressor.do(alloc, input, t);
        const formatted = if (t == .none) b: {
            break :b try alloc.dupe(u8, input);
        } else try to_hex(alloc, res);
        defer alloc.free(formatted);
        try print("\t\x1b[34mcompressed:\x1b[0m  '{s}'\n", .{formatted});

        const undone = try compressor.undo(alloc, res, t);
        try print("\t\x1b[35mdecompressed:\x1b[0m  '{s}'\n", .{undone});

        const is_eql = std.mem.eql(u8, undone, input);
        std.debug.assert(is_eql);
    }
}

fn print(comptime fmt:[]const u8, args:anytype) !void {
    var buf:[1024]u8 = undefined;
    var wr = std.fs.File.stdout().writer(&buf);
    const stdout = &wr.interface; 
    try stdout.print(fmt, args);
    try stdout.flush();
}

fn to_hex(alloc:std.mem.Allocator, bytes:[]const u8) ![]const u8 {
    var res = try std.ArrayList(u8).initCapacity(alloc, 0);
    defer _ = res.deinit(alloc);
    for (bytes) |b| for ([_][]const u8 {
        "\x1b[36m\\x",
        try std.fmt.allocPrint(alloc, "{x}", .{b}),
        "\x1b[0m"
    }) |s| try res.appendSlice(alloc, s);
    return try alloc.dupe(u8, res.items);
}

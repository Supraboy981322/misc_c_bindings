const std = @import("std");
const mem = std.mem;
const types = @import("types.zig");
const compress = @cImport({
    @cInclude("compress.h");
});

fn const_u8_to_c_str(
    in_R:[]const u8,
    alloc:mem.Allocator
) !struct { ptr:[*c]u8, raw:[:0]u8 } {
    //duplicate into mutable from immutable
    const in:[]u8 = try alloc.dupe(u8, in_R);
    defer alloc.free(in);

    //allocate duplicate with null terminator (C compat) 
    const in_C:[:0]u8 = try alloc.dupeZ(u8, in);

    //get *char 
    const in_C_ptr:[*c]u8 = in_C.ptr;

    return .{ .ptr = in_C_ptr, .raw = in_C };
}

fn c_str_to_const_u8(
    alloc:mem.Allocator,
    c_str:[*c]u8,
    len:usize,
) ![]const u8 {
    //convert to a slice
    const compressed = c_str[0..len];

    //return as new allocated slice so the C stuff can be freed 
    return try alloc.dupe(u8, compressed);
}

fn attempt_unwrap(
    alloc:mem.Allocator,
    comp:?compress.res
) ![]const u8 {
    //make sure the struct isn't null and get it
    const com = if (comp) |com| com else {
        return error.FailedToCompress;
    };

    //make sure the content isn't null and get it
    const res = if (com.cont) |res| res else {
        return error.FailedToCompress;
    };

    //return converted to Zig string
    return try c_str_to_const_u8(
        alloc, res, @intCast(com.leng)
    );
}

pub fn do(
    alloc: mem.Allocator,
    in_R: []const u8,
    enc: types.Compression, //which compression type to use
) ![]const u8 {

    //if too large to handle currently, just return input  TODO: i64
    if (in_R.len > std.math.maxInt(i32)) return in_R;

    const in = try const_u8_to_c_str(in_R, alloc);

    //call Go compression binding
    const comp = switch (enc) {
        .gzip => compress.Gz(in.ptr, @intCast(in.raw.len)),
        .br, .brotli => compress.Br(in.ptr, @intCast(in.raw.len)),
        .zlib => compress.Zlib(in.ptr, @intCast(in.raw.len)),
        //shouldn't happen, but just in case
        .none => compress.res{
            .cont = in.ptr,
            .leng = @intCast(in.raw.len),
        },
    };

    //return unwrapped
    return try attempt_unwrap(alloc, comp);
}

pub fn undo(
    alloc: mem.Allocator,
    in_R: []const u8,
    enc: types.Compression,
) ![]const u8 {
    //too large to handle currently  TODO: i64
    if (in_R.len > std.math.maxInt(i32)) return in_R;

    const in = try const_u8_to_c_str(in_R, alloc);

    //compress
    const comp = switch (enc) {
        .gzip => compress.De_Gz(in.ptr, @intCast(in.raw.len)),
        .br, .brotli => compress.De_Br(in.ptr, @intCast(in.raw.len)),
        .zlib => compress.De_Zlib(in.ptr, @intCast(in.raw.len)),
        //shouldn't happen, but just in case
        .none => compress.res{
            .cont = in.ptr,
            .leng = @intCast(in.raw.len),
        },
    };

    //return unwrapped
    return try attempt_unwrap(alloc, comp);
}

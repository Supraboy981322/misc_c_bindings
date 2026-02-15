const std = @import("std");
const go = @cImport(@cInclude("async.h"));

//adapter called by Golang over C ABI when dispatching an fn with a void* param
export fn void_ptr_fn_callback(f:?*anyopaque, data:?*anyopaque) callconv(.c) void {
    const func = @as(*const fn (?*anyopaque) callconv(.c) void, @ptrCast(@alignCast(f)));
    func(data);
}

//adapter called by Golang over C ABI when dispatching a fn 
export fn fn_callback(f:?*anyopaque) callconv(.c) void {
    const func = @as(*const fn () callconv(.c) void, @ptrCast(@alignCast(f)));
    func();
}

pub fn main() !void {
    //get pointer to Zig fn
    const fn_ptr = &foo;

    const data_ptr = &struct { msg:[]const u8 } {
        .msg = "foo",
    };

    //cast it to an anyopaque to be passed over C ABI
    const f_cast:?*anyopaque = @ptrCast(@constCast(fn_ptr));
    const data_cast:?*anyopaque = @ptrCast(@constCast(data_ptr));

    std.debug.print("main: calling async\n", .{});

    //call GoRoutine
    go.async_data(f_cast, data_cast);

    std.debug.print("main: waiting 2 seconds\n", .{});

    //wait 2 seconds
    std.Thread.sleep(2000 * std.time.ns_per_ms);

    std.debug.print("main: exiting\n", .{});
}

//fn to be run async 
export fn foo(data_packed:?*anyopaque) callconv(.c) void {
    //unpack data
    const data = @as(
        *struct {
            msg:[]const u8
        },
       @ptrCast(@alignCast(data_packed))
    );
   
    //print data message
    std.debug.print("async: recieved {s}\n", .{data.msg});

    std.debug.print("async: waiting 1 second\n", .{});

    //wait 1 second
    std.Thread.sleep(1000 * std.time.ns_per_ms);

    std.debug.print("async: done\n", .{});
}

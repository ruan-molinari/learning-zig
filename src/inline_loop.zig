const std = @import("std");
const assert = std.testing.assert;

const Data = struct {
    foo: Foo,
    bytes: [8]u8,
    ok: bool,
};

const Foo = enum { hello, world };

pub fn main() void {
    var data: Data = .{
        .foo = .world,
        .bytes = "arstdhne".*,
        .ok = true,
    };
    dump(data);
}

fn dump(data: anytype) void {
    const T = @TypeOf(data);
    inline for (@typeInfo(T).Struct.fields) |field| {
        std.debug.print("{any}\n", .{@field(data, field.name)});
    }
}

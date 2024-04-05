const std = @import("std");
const assert = std.testing.assert;
const expect = std.testing.expect;

test "basic AutoArrayHashMap usage" {
    var map = std.AutoArrayHashMap(i32, i32).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, 11);
    try map.put(2, 22);
    try expect(map.get(1).? == 11);
    try expect(map.get(2).? == 22);

    {
        const gop = try map.getOrPut(3);
        if (!gop.found_existing) {
            // initialize directly into place
            gop.value_ptr.* = 33;
        }
    }

    try expect(std.mem.eql(i32, map.keys(), &.{ 1, 2, 3 }));
    try expect(std.mem.eql(i32, map.values(), &.{ 11, 22, 33 }));
}

test "using AutoArrayHashMap as an ordered set" {
    var map = std.AutoArrayHashMap(i32, void).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, {});
    try map.put(2, {});
    try expect(map.contains(1));
    try expect(map.contains(2));
    try expect(std.mem.eql(i32, map.keys(), &.{ 1, 2 }));
}

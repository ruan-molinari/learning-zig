const std = @import("std");
const testing = @import("std").testing;

const err = error{
    OutOfBounds,
};

pub fn DynamicArray(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        arr: []T,
        size: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .arr = &[_]T{},
                .size = 0,
            };
        }

        pub fn initCapacity(allocator: std.mem.Allocator, capacity: usize) !Self {
            return Self{
                .allocator = allocator,
                .arr = try allocator.alloc(T, capacity),
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.arr);
        }

        pub fn len(self: *Self) usize {
            return self.size;
        }

        pub fn push(self: *Self, value: T) !void {
            // If capacity is full the array will be resized
            if (self.arr.len == self.size) {
                var newCapacity = if (self.size == 0) 1 else 2 * self.size;
                // Reallocates the array in the heap if there is not enough
                // space on the current memory position
                if (!self.allocator.resize(self.ptr(), newCapacity)) {
                    self.arr = try self.allocator.realloc(self.ptr(), newCapacity);
                }
            }
            self.arr[self.size] = value;
            self.size += 1;
        }

        // Returns the value on requested index or OutOfBounds if exceded
        // self.size
        pub fn get(self: *Self, index: usize) error{OutOfBounds}!T {
            if (index > self.size) {
                return error.OutOfBounds;
            }
            return self.arr[index];
        }

        pub fn firstIndexOf(self: *Self, value: T) ?T {
            for (self.arr, 0..) |item, index| {
                if (item == value) return index;
            }
            return null;
        }

        pub fn pop(self: *Self) T {
            const val = self.arr[self.size - 1];
            self.size -= 1;
            return val;
        }

        pub fn log(self: *Self) void {
            std.debug.print("{any}\n", .{self.arr});
        }

        pub fn ptr(self: *Self) ![]T {
            if (self.arr.ptr == undefined) {
                return error.SegmentationFault;
            }
            return self.arr.ptr[0..self.size];
        }

        fn resize(self: *Self, newCapacity: usize) void {
            var newArr: *T = [newCapacity]T;
            for (self.arr, 0..) |value, index| {
                newArr[index] = value;
            }
            self.arr = newArr;
            self.size = newCapacity;
        }
    };
}

test "get returns correct value" {
    var arr = DynamicArray(usize).init(std.testing.allocator);
    defer arr.deinit();

    try arr.push(0);
    try arr.push(1);
    try arr.push(2);

    try testing.expectEqual(try arr.get(1), 1);
}

test "get returns out of bounds" {
    var arr = DynamicArray(usize).init(std.testing.allocator);
    defer arr.deinit();

    try testing.expect(arr.get(1) == error.OutOfBounds);
}

test "pop removes last item" {
    var arr = DynamicArray(usize).init(std.testing.allocator);
    defer arr.deinit();
}

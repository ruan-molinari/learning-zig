const std = @import("std");
const mem = std.mem;
const testing = std.testing;

fn quick_sort(arr: []i32, start: usize, end: usize) void {
    // base case size <= 1
    if (start < end) {
        var pivot = partition(arr, start, end);
        quick_sort(arr, start, @min(pivot, pivot -% 1));
        quick_sort(arr, pivot + 1, end);
    }
}

fn partition(arr: []i32, start: usize, end: usize) usize {
    var pivot_value = arr[end];
    var swap_marker = start;
    var index = start;
    while (index < end) : (index += 1) {
        if (arr[index] <= pivot_value) {
            mem.swap(i32, &arr[index], &arr[swap_marker]);
            swap_marker += 1;
        }
    }
    mem.swap(i32, &arr[swap_marker], &arr[end]);
    return swap_marker;
}

test "Check if quicksort is sorting" {
    var arr = [_]i32{ 3, 2, 5, 0, 1, 8, 7, 6, 9, 4 };
    quick_sort(&arr, 0, arr.len - 1);
    std.debug.print("{any}", .{arr});
    try testing.expectEqual(arr, .{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 });
}

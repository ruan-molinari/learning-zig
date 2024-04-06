const std = @import("std");
const testing = std.testing;

const LinkedListError = error{
    emptyList,
    nodeNotInList,
};

pub fn SinglyLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            next: ?*Node = null,

            pub const Data = T;

            pub fn insertAfter(node: *Node, new_node: *Node) void {
                new_node.next = node.next;
                node.next = new_node;
            }

            pub fn removeNext(node: *Node) void {
                node.next = node.next.?.next;
            }
        };

        first: ?*Node = null,

        pub fn prepend(self: *Self, new_node: *Node) !void {
            if (self.first != null) {
                new_node.next = self.first.?.next;
            }
            self.first = new_node;
        }

        pub fn middle(self: *Self) !T {
            var node = self.first;
            if (node != null) {
                var middle_node = self.first;
                var count: usize = 1;
                while (node.?.next != null) : (node = node.?.next) {
                    // Every 2 nodes, middle_node becomes next;
                    std.debug.print("{?}\n", .{count});
                    std.debug.print("{?}\n", .{count % 2});
                    if (count % 2 != 0) {
                        middle_node = middle_node.?.next;
                    }
                    count += 1;
                }
                return middle_node.?.data;
            }
            return LinkedListError.emptyList;
        }
    };
}

// This tests are from the zig std library's linked list
test "basic SinglyLinkedList test" {
    const L = SinglyLinkedList(u32);
    var list = L{};

    try testing.expect(list.len() == 0);

    var one = L.Node{ .data = 1 };
    var two = L.Node{ .data = 2 };
    var three = L.Node{ .data = 3 };
    var four = L.Node{ .data = 4 };
    var five = L.Node{ .data = 5 };

    list.prepend(&two); // {2}
    two.insertAfter(&five); // {2, 5}
    list.prepend(&one); // {1, 2, 5}
    two.insertAfter(&three); // {1, 2, 3, 5}
    three.insertAfter(&four); // {1, 2, 3, 4, 5}

    try testing.expect(list.len() == 5);

    // Traverse forwards.
    {
        var it = list.first;
        var index: u32 = 1;
        while (it) |node| : (it = node.next) {
            try testing.expect(node.data == index);
            index += 1;
        }
    }

    _ = list.popFirst(); // {2, 3, 4, 5}
    _ = list.remove(&five); // {2, 3, 4}
    _ = two.removeNext(); // {2, 4}

    try testing.expect(list.first.?.data == 2);
    try testing.expect(list.first.?.next.?.data == 4);
    try testing.expect(list.first.?.next.?.next == null);

    L.Node.reverse(&list.first);

    try testing.expect(list.first.?.data == 4);
    try testing.expect(list.first.?.next.?.data == 2);
    try testing.expect(list.first.?.next.?.next == null);
}

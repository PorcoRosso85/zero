const std = @import("std");

// 招待する人、招待される人の構造
pub const person = struct {
    name: []const u8,
    age: i8,
    email: []const u8,
};

pub const invitation = struct {
    inviter: person,
    invitee: person,
};

pub fn invite(inviter: person, invitee: person) invitation {
    return invitation{
        .inviter = inviter,
        .invitee = invitee,
    };
}

test "invite" {
    const inviter = person{
        .name = "Alice",
        .age = 20,
        .email = "alice@mail.com",
    };
    const invitee = person{
        .name = "Bob",
        .age = 25,
        .email = "bob@mail.com",
    };
    const inviting = invite(inviter, invitee);
    std.debug.print("{s} inviting, {s} invited \n", .{ inviting.inviter.name, inviting.invitee.name });

    try std.testing.expectEqual("Alice", inviting.inviter.name);
}

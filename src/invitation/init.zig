const std = @import("std");

// 招待する人、招待される人の構造
pub const Person = struct {
    name: []const u8,
    age: i8,
    email: []const u8,
};

pub const Invitation = struct {
    inviter: Person,
    invitee: Person,
};

pub fn invite(inviter: Person, invitee: Person) Invitation {
    return Invitation{
        .inviter = inviter,
        .invitee = invitee,
    };
}

test "invite" {
    const inviter = Person{
        .name = "Alice",
        .age = 20,
        .email = "alice@mail.com",
    };
    const invitee = Person{
        .name = "Bob",
        .age = 25,
        .email = "bob@mail.com",
    };
    const inviting = invite(inviter, invitee);
    std.debug.print("{s} inviting, {s} invited \n", .{ inviting.inviter.name, inviting.invitee.name });

    try std.testing.expectEqual("Alice", inviting.inviter.name);
}

pub const InvitationResponse = enum {
    Accepted,
    Rejected,
};

pub fn respond(_invitation: Invitation, response: InvitationResponse) ![]const u8 {
    const allocator = std.heap.page_allocator();
    return switch (response) {
        .Accepted => std.fmt.allocPrint(allocator, "{s} has accepted the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
        .Rejected => std.fmt.allocPrint(allocator, "{s} has rejected the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
    };
}

test "respond" {
    const inviter = Person{
        .name = "Alice",
        .age = 20,
        .email = "alice@mail.com",
    };
    const invitee = Person{
        .name = "Bob",
        .age = 25,
        .email = "bob@mail.com",
    };
    const invitation = invite(inviter, invitee);
    const response = respond(invitation, .Accepted);

    std.testing.expectEqual("Bob has accepted the invitation from Alice.\n", response);
}

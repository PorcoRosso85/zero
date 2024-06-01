const std = @import("std");

// person 構造体の name と email フィールドは、現在 []const u8 型（つまり、不変のu8の配列）として定義されています。これは、文字列の長さが可変であることを意味しますが、これは必ずしも効率的ではありません。可能であれば、これらのフィールドの長さを制限することで、メモリ使用量を削減できます。
pub const Person = struct {
    name: []const u8,
    age: u7,
    email: []const u8,
};

pub const Invitation = struct {
    inviter: Person,
    invitee: Person,
};

// invite 関数と respond 関数は、それぞれ person 構造体と Invitation 構造体のコピーを作成します。これはメモリを無駄にする可能性があります。代わりに、これらの関数に構造体の参照を渡すことを検討してみてください。
pub fn invite(inviter: *const Person, invitee: *const Person) Invitation {
    return Invitation{
        .inviter = inviter.*,
        .invitee = invitee.*,
    };
}

// テストケースでは、同じ person 構造体が複数回作成されています。これはメモリの無駄です。代わりに、テストケースのセットアップ部分で一度だけ person 構造体を作成し、それを各テストケースで再利用することを検討してみてください。
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
    // &演算子は、変数のアドレスを取得するために使用されます。これにより、変数への参照（またはポインタ）が作成されます。例えば、&variableとすると、variableへのポインタが得られます。
    // *演算子は、ポインタが指すアドレスの値を取得するために使用されます。これはデリファレンス（参照の解除）と呼ばれます。例えば、*pointerとすると、pointerが指すアドレスの値が得られます。
    const inviting = invite(&inviter, &invitee);
    std.debug.print("{s} inviting, {s} invited \n", .{ inviting.inviter.name, inviting.invitee.name });

    try std.testing.expectEqual("Alice", inviting.inviter.name);
}

pub const InvitationResponse = enum {
    Accepted,
    Rejected,
};

// invite 関数と respond 関数は、それぞれ person 構造体と Invitation 構造体のコピーを作成します。これはメモリを無駄にする可能性があります。代わりに、これらの関数に構造体の参照を渡すことを検討してみてください。
// respond 関数では、レスポンスメッセージを生成するために std.fmt.allocPrint を使用しています。これは新しい文字列をメモリに割り当て、その後すぐに破棄されます。これはメモリの無駄です。代わりに、固定長のバッファを使用してメッセージを生成し、そのバッファを返すことを検討してみてください。
pub fn respond(_invitation: *const Invitation, response: InvitationResponse) ![]const u8 {
    var buffer: [128]u8 = undefined;
    return switch (response) {
        // .Accepted => std.fmt.allocPrint(allocator, "{s} has accepted the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
        .Accepted => try std.fmt.bufPrint(&buffer, "{s} has accepted the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
        // .Rejected => std.fmt.allocPrint(allocator, "{s} has rejected the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
        .Rejected => try std.fmt.bufPrint(&buffer, "{s} has rejected the invitation from {s}.\n", .{ _invitation.invitee.name, _invitation.inviter.name }),
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
    const invitation = invite(&inviter, &invitee);
    const response = try respond(&invitation, .Accepted);

    try std.testing.expectEqualStrings("Bob has accepted the invitation from Alice.\n", response);
}

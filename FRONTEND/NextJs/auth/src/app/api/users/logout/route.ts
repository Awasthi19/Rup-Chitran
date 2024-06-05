import { NextResponse } from "next/server";

export async function GET() {
    try {
        const response = NextResponse.json(
            { message: "User logged out successfully" }
        );  
        console.log("response", response);
        response.cookies.set("token", "", {
            httpOnly: true,
            expires: new Date(0)
        });
        return response;

    } catch (error) {
        return NextResponse.json({ message: "An error occurred" });
    }   
}

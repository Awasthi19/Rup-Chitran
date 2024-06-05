import { getDataFromToken } from "@/helpers/getDataFromToken";
import { NextRequest, NextResponse } from "next/server";
import User from "@/models/userModel";
import { Connect } from "@/dbConfig/dbConfig";

Connect()

export async function GET(request: NextRequest) {
    try {
        const id = await getDataFromToken(request)
        const user = await User.findById(id).
            select('-password')
        return NextResponse.json({
            message: 'User Found',
            data: user
        })

    }
    catch (error) {
        return NextResponse.json({
            message: 'An error occurred'
        })
    }

}
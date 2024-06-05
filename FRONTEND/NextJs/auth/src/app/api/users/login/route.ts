import {Connect} from "@/dbConfig/dbConfig";
import User from "@/models/userModel";
import {NextRequest, NextResponse} from "next/server";
import bcryptjs from 'bcryptjs';
import jwt from 'jsonwebtoken';

Connect()

export async function POST(request: NextRequest, response: NextResponse) {

    try {
        const reqBody = await request.json()
        const {email, password} = reqBody

        console.log(reqBody)

        const user = await User.findOne({
            email
        })

        if(!user) {
            return NextResponse.json({
                message: 'User does not exist'
            })
        }

        const validPassword = await bcryptjs.compare(password, user.password)
        if(!validPassword) {
            return NextResponse.json({
                message: 'Invalid password'
            })
        }

        // Generate token

        const tokenData = {
            id: user._id,
            email: user.email
        }
        const token = await jwt.sign(tokenData, process.env.JWT_SECRET!, {
            expiresIn: '1h'
        })

        const response = NextResponse.json({
            message: 'Login successful',
            success: true
        })
        response.cookies.set('token', token, {
            httpOnly: true,
        })
        return response 
        
    }
    catch (error) {
        return NextResponse.json({
            message: 'An error occurred'
        })
        
    }
}

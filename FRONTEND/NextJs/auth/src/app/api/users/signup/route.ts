import {Connect} from "@/dbConfig/dbConfig";
import User from "@/models/userModel";
import {NextRequest, NextResponse} from "next/server";
import bcryptjs from 'bcryptjs';

Connect();

export async function POST(request: NextRequest) {
    try {
        const reqBody = await request.json()
        const {email, password} = reqBody

        console.log(reqBody)

        //check if user already exists
        const user = await User.findOne({email})
        if(user) {
            return NextResponse.json({message: 'User already exists'})
        }

        //hashed password
        const salt = await bcryptjs.genSalt(10)
        const hashedPassword = await bcryptjs.hash(password, salt)

        const newUser = new User({email, password: hashedPassword})
        const savedUser = await newUser.save()
        
        return NextResponse.json({
            message: 'User created successfully',
            success: true,
            savedUser

        })
    }
    catch (error) {
        return NextResponse.json({message: 'An error occurred'})
    }
}

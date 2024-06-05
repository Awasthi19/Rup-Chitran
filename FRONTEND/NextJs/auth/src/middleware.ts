import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
 
// This function can be marked `async` if using `await` inside
export function middleware(request: NextRequest) {
    console.log("middleware")

    const path = request.nextUrl.pathname;
    const token = request.cookies.get('jwt')?.value||false;

    if(!token && path === '/profile') {
        console.log("redirecting to login")
        return NextResponse.redirect(new URL('/login', request.nextUrl))
    }
}

// See "Matching Paths" below to learn more
export const config = {
    matcher: [
        '/profile'
    ]
}
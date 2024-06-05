"use client"
import React, { useEffect } from 'react'
import axios from 'axios'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { set } from 'mongoose'
import { get } from 'http'
import { NextRequest } from 'next/server'



function Profile() {

    const router = useRouter()
    const [data, setData] = React.useState<any>(null)

    const handleLogout = async (e:React.MouseEvent<HTMLButtonElement>) => {
        e.preventDefault()
        try {
            await axios.get('/api/users/logout')
            router.push('/login')
        } catch (error:any) {   
            console.log(error.message)
        }
    }

    useEffect(() => {
    const getUser = async () => {
        try {
            const token= document.cookie.split('=')[1]
            const datatosend = {
                jwt: token,
            }
            console.log(datatosend)

            const res = await axios.get(process.env.NEXT_PUBLIC_PROFILE_URL!,{
                params: datatosend,
            })
            console.log(res.data.email)
            setData(res.data.email)
        } catch (error:any) {
            console.log(error.message)
        }
    }
    getUser()
    }  ,[])


  return (
    <div>
        <div>Profile</div>
        <h1>{data===null ? "Nothing":<Link
        href={`/profile/${data}`}
        >
        visit profile
        </Link>}</h1>
        <button
            className='bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded'
            onClick={handleLogout}
        >Log Out</button>

    </div>

  )
}

export default Profile
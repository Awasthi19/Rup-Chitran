"use client"
import React, { useEffect,useState } from 'react'
import { useRouter } from 'next/navigation'
import axios from 'axios'
import Image from 'next/image'
import toast from 'react-hot-toast'


interface User {
    username: string,
    email: string,
    password: string
}

function Signup() {
    
    const router = useRouter()
    const [user, setUser] = useState<User>({
        username: '',
        email: '',
        password: ''
    })

    const [buttonDisabled, setButtonDisabled] = useState<boolean>(true)
    const [loading, setLoading] = useState<boolean>(false)  

    useEffect(() => {
        if(user.email !== '' && user.password !== '') {
            setButtonDisabled(false)
        } else {
            setButtonDisabled(true)
        }
    }, [user])

    const handleChanges = (e: React.ChangeEvent<HTMLInputElement>) => { 
        setUser({...user, [e.target.name]: e.target.value})
        console.log(user)
    }

    const handleSubmit = async (e:React.MouseEvent<HTMLButtonElement>) => {
        e.preventDefault()
        try {
            setLoading(true)
            console.log(user)
            const formData = new FormData()
            user.username="rupchitran"
            formData.append('username', user.username)
            formData.append('email', user.email)
            formData.append('password', user.password)
            const response = await axios.post(process.env.NEXT_PUBLIC_SIGNUP_URL!, formData)
            console.log("response", response)
            router.push('/login')
        } catch (error:any) {
           console.log(error.message)
           toast.error(error.message)
        } finally {
            setLoading(false)
        }
    }

  return (
    <>
        <div className="flex min-h-full flex-1 flex-col justify-center px-6 py-12 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-sm flex flex-col gap-2 items-center">
          <Image
            width={200}
            height={200}
            priority={true}
            src="/Logo.png"
            alt="Logo"
          />
          <h2 className=" text-center text-2xl font-bold leading-9 tracking-tight text-yellow-600">
            {loading ? 'Loading...' : 'Sign Up'}
          </h2>
        </div>

        <div className="mt-10 sm:mx-auto sm:w-full sm:max-w-sm">
          <form className="space-y-6" action="#" method="POST">
            <div>
              <label htmlFor="email" className="block text-sm font-medium leading-6 text-white">
                Email address
              </label>
              <div className="mt-2">
                <input
                  id="email"
                  name="email"
                  type="email"
                  placeholder='     Email'
                  autoComplete="email"
                  required
                  className="block w-full rounded-md border-0 py-1.5 text-gray-900 bg-yellow-100 shadow-sm ring-0.5 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                  value={user.email}
                  onChange={handleChanges}
                />
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between">
                <label htmlFor="password" className="block text-sm font-medium leading-6 text-white">
                  Password
                </label>
                
              </div>
              <div className="mt-2">
                <input
                  id="password"
                  name="password"
                  type="password"
                  placeholder='     Password'
                  autoComplete="current-password"
                  required
                  className="block w-full bg-yellow-100 rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                  value={user.password}
                  onChange={handleChanges}
                />
              </div>
            </div>

            <div>
              
                <button
                  type="submit"
                  className={`${buttonDisabled?'bg-gray-600':'bg-yellow-600'}  flex w-full justify-center rounded-md  px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600`}
                  onClick={handleSubmit}
                >
                  Sign Up
                </button>
              
            </div>
          </form>

          
        </div>

      </div>
    </>
  )
}

export default Signup
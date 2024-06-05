import React from 'react'

function UserProfile({params}:any) {
  return (
    <div className='flex items-center gap-1 h-screen justify-center'>
        <div className='text-2xl'>UserProfile</div>
        <div className='bg-orange-500 text-2xl border-none rounded-md'>{params.userId}</div>
    </div>
  )
}

export default UserProfile
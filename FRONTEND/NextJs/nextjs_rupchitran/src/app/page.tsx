import React from 'react'
import Cam from '@/components/cam'
import GetPost from '@/components/getpost'
import Card from '@/components/card'

function Home() {
  return (
    <div className='flex flex-col space-y-5 items-center'>
      <div style={{ maxWidth: '500px', maxHeight: '500px' }}> 
        <Cam />
      </div>
      <div style={{ maxWidth: '500px', maxHeight: '500px' }}> 
        
      </div>
    </div>
  )

  
}

export default Home
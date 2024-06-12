import React from 'react'
import Cam from '@/components/cam'


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
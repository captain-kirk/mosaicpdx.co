import Layout from '../src/components/Layout';
import { useState } from 'react';

export default function Home() {
  const [showModal, setShowModal] = useState(false);
  const [email, setEmail] = useState('');

  const handleButtonClick = () => {
    setShowModal(true);
  };

  const handleCloseModal = () => {
    setShowModal(false);
    setEmail('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      // Using AWS Lambda + DynamoDB via API Gateway
      // Get the AWS API Gateway endpoint from environment variable
      const API_ENDPOINT = process.env.NEXT_PUBLIC_AWS_API_GATEWAY_URL;
      
      const response = await fetch(`${API_ENDPOINT}/submit-email`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email,
          source: 'Join the Movement Button'
        })
      });
      
      const result = await response.json();
      
      if (response.ok) {
        console.log('Email submitted successfully:', email);
        if (result.duplicate) {
          alert('Thank you! Your email is already in our system.');
        } else {
          alert('Thank you!Your email has been submitted.');
        }
      } else {
        throw new Error(result.error || 'Failed to submit');
      }
      
    } catch (error) {
      console.error('Error submitting email:', error);
      alert('There was an error submitting your email. Please try again.');
    }
    
    handleCloseModal();
  };

  return (
    <>
      <div className="full-page-background"></div>
      <Layout>
        <div style={{ 
          display: 'flex', 
          flexDirection: 'column',
          justifyContent: 'center', 
          alignItems: 'center',
          width: '100%',
          marginTop: '2rem'
        }}>
          <img 
            src="/images/mosaic.png" 
            alt="Mosaic" 
            style={{ 
              maxWidth: '600px', 
              width: '100%', 
              height: 'auto'
            }} 
          />
          <>
            <h1 className="movement-title">building community one piece at a time</h1>
          </>
          <button className="movement-button" onClick={handleButtonClick}>
            Join the Movement
          </button>
        </div>

        {/* Email Modal */}
        <div className={`email-modal ${showModal ? '' : 'hidden'}`}>
          <div className="email-modal-content">
            <h2>Join the Movement</h2>
            <p>Enter your email to stay connected with our community!</p>
            <form onSubmit={handleSubmit}>
              <input
                type="email"
                placeholder="Enter your email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <div className="email-modal-buttons">
                <button type="submit" className="email-submit-btn">
                  Submit
                </button>
                <button type="button" className="email-cancel-btn" onClick={handleCloseModal}>
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      </Layout>
    </>
  );
}
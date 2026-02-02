import Layout from '../src/components/Layout';
import { useState, useEffect } from 'react';

// In development, uses mock data from public/. In production builds, fetches from S3 via API.
const USE_MOCK = process.env.NODE_ENV === 'development';

const MOCK_UPCOMING = [
  { url: '/events/upcoming/birthday.png', key: 'events/upcoming/oasis.png', lastModified: '2026-03-15T00:00:00.000Z' },
];

const MOCK_PAST = [
  { url: '/events/past/oasis.png', key: 'events/past/oasis.png', lastModified: '2026-03-15T00:00:00.000Z' },
];

export default function Events() {
  const [upcoming, setUpcoming] = useState([]);
  const [past, setPast] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchFlyers = async () => {
      if (USE_MOCK) {
        setUpcoming(MOCK_UPCOMING);
        setPast(MOCK_PAST);
        setLoading(false);
        return;
      }

      try {
        const API_ENDPOINT = process.env.NEXT_PUBLIC_AWS_API_GATEWAY_URL;
        const response = await fetch(`${API_ENDPOINT}/event-flyers`);

        if (!response.ok) {
          throw new Error('Failed to fetch events');
        }

        const data = await response.json();
        setUpcoming(data.upcoming || []);
        setPast(data.past || []);
      } catch (err) {
        console.error('Error fetching event flyers:', err);
        setError('Unable to load events. Please try again later.');
      } finally {
        setLoading(false);
      }
    };

    fetchFlyers();
  }, []);

  return (
    <>
      <div className="full-page-background"></div>
      <Layout>
        <div className="events-page">

          {loading && (
            <div className="text-center my-5">
              <div className="spinner-border text-light" role="status">
                <span className="visually-hidden">Loading...</span>
              </div>
            </div>
          )}

          {error && (
            <div className="alert alert-warning text-center" role="alert">
              {error}
            </div>
          )}

          {!loading && !error && (
            <>
              <h2 className="events-section-title">Upcoming Events</h2>
              {upcoming.length === 0 ? (
                <p className="events-empty">No upcoming events. Check back soon!</p>
              ) : (
                <div className="events-list">
                  {upcoming.map((flyer) => (
                    <div key={flyer.key} className="events-flyer-item">
                      <img
                        src={flyer.url}
                        alt="Event flyer"
                        className="events-flyer-img"
                      />
                    </div>
                  ))}
                </div>
              )}

              <h2 className="events-section-title events-past-title">Past Events</h2>
              {past.length === 0 ? (
                <p className="events-empty">No past events yet.</p>
              ) : (
                <div className="events-list">
                  {past.map((flyer) => (
                    <div key={flyer.key} className="events-flyer-item">
                      <img
                        src={flyer.url}
                        alt="Event flyer"
                        className="events-flyer-img"
                      />
                    </div>
                  ))}
                </div>
              )}
            </>
          )}
        </div>
      </Layout>
    </>
  );
}

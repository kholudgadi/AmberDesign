# Requirements mapping

This document reconciles the Arabic project specification with the earlier English timeline.

| Requirement area | Implementation | Status |
| --- | --- | --- |
| FR-01 order tracking | Orders plus immutable `statusHistory` and validated transitions | Implemented |
| FR-02 Arabic/English | Bilingual content fields and user language preference | Backend implemented |
| FR-04/16 backend, dashboard, RBAC | Express API, Firebase token verification, role middleware/rules | Implemented |
| FR-05 accounts/packages | Auth/profile roles implemented; billing provider pending | Partial |
| FR-06 AI taste analysis | Durable async `aiJobs` API | Provider worker pending |
| FR-07 store/payments | Catalog/order/payment model | Gateway credentials pending |
| FR-08 points/challenges | Points field, challenges and entries | Redemption/award worker pending |
| FR-09 design-and-market | Can use uploads plus AI jobs | Generative provider/templates pending |
| FR-10 trends | Trends API/collection | Implemented |
| FR-11 ads/sponsorships | Data model can be added without migration | Campaign delivery pending |
| FR-12/20/26 analytics | Activity events and admin counts/revenue | Basic implementation |
| FR-13 notifications | FCM topic campaign API | Implemented; credentials required |
| FR-14/19 CMS/pages | Categories and dynamic pages | Implemented |
| FR-15 ratings/comments | Catalog reviews and community comments | Implemented |
| FR-17 helpdesk | Tickets, replies, priority/status | Implemented |
| FR-18 search/filter | Category/type filters and small-catalog text fallback | Dedicated search recommended |
| FR-21 moderation/bans | Account disable, item moderation, staff roles | Implemented |
| FR-22 social login/share | Firebase Auth-compatible backend | Flutter provider setup pending |
| FR-24 designer dashboard | Owner-scoped catalog/order APIs | Implemented |
| FR-25 customer system | Orders, purchases, favorites, points profile | Implemented |

## Architecture decision

PostgreSQL through Prisma is the authoritative application database. Socket.io provides authenticated real-time chat rooms and events. Firebase is limited to optional FCM, Storage, and phone OTP integrations and does not store application records.

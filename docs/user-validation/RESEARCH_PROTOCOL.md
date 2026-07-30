# YouNew User Outcome Study — protocol v1 draft

## Research question

Can a newcomer complete the BRP journey and one additional critical journey
using YouNew, without critical error, external search or human help, while
opening and understanding the official source?

This protocol is a draft until a human research owner and privacy reviewer
approve it.

## Participants and observations

- 10 newcomers in the Netherlands;
- each participant completes BRP plus one of DigiD, huisarts, zorgtoeslag or
  employment;
- 20 observations total;
- no task hints except a predefined safety stop;
- assignment of the second task is balanced before recruitment;
- the moderator does not rescue a participant to improve a score.

## Time targets

| Journey | Target |
| --- | ---: |
| BRP | 10 minutes |
| DigiD | 8 minutes |
| Huisarts | 8 minutes |
| Zorgtoeslag | 10 minutes |
| Employment | 10 minutes |

## Observation fields

Only these structured values may be recorded:

- random research session UUID;
- journey;
- completed: yes/no;
- source opened: yes/no;
- wrong-turn count;
- external-search count;
- human-help flag;
- critical-error flag;
- duration in seconds;
- safety-stop flag;
- observation timestamp.

Do not record BSN, medical data, credentials, contacts, free-form form text,
IP address or user-agent.

## Predefined gate

The User Outcome Gate passes only when all conditions hold:

- overall completion at least 80%;
- BRP completion at least 80%;
- zero critical errors;
- source-open rate at least 70%;
- median wrong turns at most 1;
- external searches at most 1 per observation;
- human help equals 0;
- journey-specific time targets pass.

Missing or invalid observations do not count as success. Inconclusive evidence
keeps the gate blocked.

## Safety stop

The moderator stops the task when continuing could expose a credential,
sensitive personal information, unsafe medical behavior, missed legal deadline
or material financial harm. A safety stop is not silently counted as
completion. The event is escalated as a critical issue without recording the
sensitive value.

## Procedure

1. Confirm approved protocol version and separate consent.
2. Generate a random session UUID unrelated to account or device identity.
3. Explain that the product is under evaluation and is not an authority.
4. Start the assigned task and timer.
5. Record only the predefined counters and flags.
6. Stop when completed, timed out or safety-stop criteria are met.
7. Review the observation for completeness without changing the outcome.
8. Store it only after `research_ingestion` has been separately approved and
   enabled.
9. Delete the observation no later than 90 days after creation.

## Analysis

Report numerator, denominator, exclusions and confidence limitations for every
metric. Segment BRP from second journeys. Do not average away a critical
failure. The scorecard remains diagnostic; the pass/fail gate is authoritative.

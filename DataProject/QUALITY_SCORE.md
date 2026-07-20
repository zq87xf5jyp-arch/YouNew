# DATA PROJECT Quality Score

Quality Score is calculated per record and averaged per Work Package. It is evidence-based and cannot be manually overridden.

| Component | Weight | Pass condition |
| --- | ---: | --- |
| Completeness | 20% | All canonical required fields are present. |
| Verification | 20% | Status is verified and `last_checked + review_frequency_days` is current. |
| Official source | 20% | Exact HTTPS page, official publisher, and `verified_opened` status. |
| Media | 15% | Verified hero, gallery, thumbnail, and map preview with licence and attribution. |
| Geography | 10% | Geographic entities have a province and coordinates inside the Netherlands. |
| Search | 10% | At least three unique search keywords. |
| AI | 5% | A non-placeholder AI summary of at least 40 characters. |

A package with no DATA PROJECT records scores 0%. Legacy runtime content is not scored until it has been audited and migrated into a governed batch.

Quality Score measures record readiness. Coverage measures breadth. A high score with low coverage is therefore possible and must not be presented as database completeness.

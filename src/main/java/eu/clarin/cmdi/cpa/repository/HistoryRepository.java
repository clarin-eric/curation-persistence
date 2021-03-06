package eu.clarin.cmdi.cpa.repository;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;

import eu.clarin.cmdi.cpa.model.History;

public interface HistoryRepository extends PagingAndSortingRepository<History, Long> {
   
   @Query(
         value = "INSERT INTO obsolete (url_name, client_email, providergroup_name, origin, expected_mime_type, ingestion_date, status_code, message, category, method, content_type, content_length, duration, checking_date, redirect_count) "
               + "SELECT u.name, cl.email, p.name, c.origin, c.expected_mime_type, uc.ingestion_date, h.status_code, h.message, h.category, h.method, h.content_type, h.content_length, h.duration, h.checking_date, h.redirect_count "
               + "FROM url_context uc "
               + "INNER JOIN (url u) "
               + "ON u.id=uc.url_id "
               + "INNER JOIN (context c) "
               + "ON c.id=uc.context_id "
               + "INNER JOIN providergroup p "
               + "ON p.id=c.providergroup_id "
               + "INNER JOIN history h "
               + "ON h.url_id=u.id "
               + "INNER JOIN client cl "
               + "ON cl.id=c.client_id "
               + "WHERE uc.ingestion_date < ?1",
         nativeQuery = true
      )
   @Modifying
   public void saveHistoryLinksOlderThan(int persiodOfDays);

}
